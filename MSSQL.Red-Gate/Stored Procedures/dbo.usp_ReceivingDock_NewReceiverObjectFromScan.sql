SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[usp_ReceivingDock_NewReceiverObjectFromScan]
	@User varchar(5)
,	@PONumber int
,	@Part varchar(25)
,	@Quantity numeric(20,6)
,	@SupplierLicensePlate varchar(50)
,	@ReceiverObjectId int out
,	@TranDT datetime = null out
,	@Result integer = null out
as
set nocount on
set ansi_warnings off
set	@Result = 999999

--- <Error Handling>
declare
	@CallProcName sysname,
	@TableName sysname,
	@ProcName sysname,
	@ProcReturn integer,
	@ProcResult integer,
	@Error integer,
	@RowCount integer

set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. dbo.usp_Test
--- </Error Handling>

--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
declare
	@TranCount smallint

set	@TranCount = @@TranCount
if	@TranCount = 0 begin
	begin tran @ProcName
end
else begin
	save tran @ProcName
end
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>

---	<ArgumentValidation>
/*	Specified PO Number and Part must be valid. */
declare
	@VendorCode varchar(10)

select
	@VendorCode = ph.vendor_code
from
	dbo.po_header ph
where
	ph.po_number = @PONumber

if	@VendorCode is null begin

	set @Result = 999999
	RAISERROR ('Invalid Blanket PO %d for this part %s in procedure %s.', 16, 1, @PONumber, @Part, @ProcName)
	rollback tran @ProcName
	return
end

/*	There must be an available receiver header. */
declare
	@ReceiverID int

select
	@ReceiverID =
		(	select
				rh.ReceiverID
			from
				dbo.ReceiverHeaders rh
			where
				rh.Status in (0, 1, 2, 3, 4)
				and rh.ShipFrom in
					(	select
							d.destination
						from
							dbo.destination d
						where
							d.vendor = @VendorCode
					)
		)

if	@ReceiverID is null begin

	set @Result = 999999
	RAISERROR ('No open receivers were found for vendor %s in procedure %s.', 16, 1, @VendorCode, @ProcName)
	rollback tran @ProcName
	return
end

---	</ArgumentValidation>

/*	See what's on po_detail. */
declare
	@Requirements table
(	ReceiverID int
,	PartCode varchar(25)
,	PONumber integer
,	POLineNo integer
,	POLineDueDate datetime
,	PackageType varchar(20)
,	POBalance numeric(20,6)
,	StdPackQty numeric(20,6)
,	PriorAccum numeric(20,6)
,	PostAccum numeric(20,6)
,	RowID int not null IDENTITY(1, 1) primary key
)

/*	Get first requirements for this part. */
--- <Insert>
set @TableName = '@Requirements'

insert
	@Requirements
(	ReceiverID
,	PartCode
,	PONumber
,	POLineNo
,	POLineDueDate
,	PackageType
,	POBalance
,	StdPackQty
)
select top 1
	ReceiverID = @ReceiverID
,	PartCode = pd.part_number
,	PONumber = pd.po_number
,	POLineNo = coalesce
		(	case
				when ph.release_control = 'L' then pd.row_id
			end
		,	(	select top 1
					pd2.row_id
				from
					dbo.po_detail pd2
				where
					pd2.po_number = @PONumber
					and pd2.balance > 0
				order by
					pd2.date_due asc
			)
		)
,	POLineDueDate = min(pd.date_due)
,	PackageType =
		(	select
				min(part_packaging.code)
			from
				dbo.part_packaging part_packaging
			where
				part_packaging.part = pd.part_number
				and part_packaging.quantity = PartSupplierStdPack.StdPack
		)
,	POBalance = sum(pd.balance)
,	StdPackQty = coalesce(PartSupplierStdPack.StdPack, sum(pd.balance))
from
	dbo.po_detail pd
	join dbo.po_header ph
		on pd.po_number = ph.po_number
	left join
		(	select
				Part = p.part
			,	SupplierCode = pv.vendor
			,	StdPack = coalesce(nullif(pv.vendor_standard_pack, 0.0), nullif(pi.standard_pack, 0.0), -1)
			from
				dbo.part p
				left join dbo.part_inventory pi
					on p.part = pi.part
				left join dbo.part_vendor pv
					on p.part = pv.part
		) PartSupplierStdPack
		on pd.part_number = PartSupplierStdPack.Part
			and pd.vendor_code = PartSupplierStdPack.SupplierCode
where
	pd.po_number = @PONumber
	and pd.balance > 0
group by
	pd.po_number
,	pd.part_number
,	PartSupplierStdPack.StdPack
,	case
		when ph.release_control = 'L' then pd.row_id
	end
	
/*	Create a receiver line if necessary. */
if	not exists
	(	select
			*
		from
			dbo.ReceiverLines rl
			join @Requirements r
				on rl.ReceiverID = r.ReceiverID
				and rl.PONumber = r.PONumber
				and rl.POLineNo = r.POLineNo
	) begin

	--- <Insert rows="1">
	set	@TableName = 'dbo.ReceiverLines'
	
	insert
		dbo.ReceiverLines
	(	ReceiverID
	,	[LineNo]
	,	PartCode
	,	PONumber
	,	POLineNo
	,	POLineDueDate
	,	PackageType
	,	RemainingBoxes
	,	StdPackQty
	)
	select
		ReceiverID = r.ReceiverID
	,	[LineNo] = coalesce
			(	(	select
			 			max(rl.[LineNo]) + 1
			 		from
			 			dbo.ReceiverLines rl
						join @Requirements r
							on rl.ReceiverID = r.ReceiverID
			 	)
			,	1
			)
	,	PartCode = r.PartCode
	,	PONumber = r.PONumber
	,	POLineNo = r.POLineNo
	,	POLineDueDate = r.POLineDueDate
	,	PackageType = r.PackageType
	,	RemainingBoxes = 0
	,	StdPackQty = @Quantity
	from
		@Requirements r

	select
		@Error = @@Error,
		@RowCount = @@Rowcount
	
	if	@Error != 0 begin
		set	@Result = 999999
		RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
		rollback tran @ProcName
		return
	end
	if	@RowCount != 1 begin
		set	@Result = 999999
		RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
		rollback tran @ProcName
		return
	end
	--- </Insert>
end

--- <Insert rows="1">
set	@TableName = 'dbo.ReceiverObjects'

insert
	dbo.ReceiverObjects
(	ReceiverLineID
,	[LineNo]
,	Status
,	PONumber
,	POLineNo
,	POLineDueDate
,	PartCode
,	PartDescription
,	EngineeringLevel
,	QtyObject
,	PackageType
,	Location
,	Plant
,	DrAccount
,	CrAccount
,	SupplierLicensePlate)
select
	rl.ReceiverLineID
,	[LineNo] = coalesce
		(	(	select
			 		max(ro.[LineNo]) + 1
			 	from
			 		dbo.ReceiverLines rl
						join @Requirements r
							on rl.ReceiverID = r.ReceiverID
					join dbo.ReceiverObjects ro
						on ro.ReceiverLineID = rl.ReceiverLineID
			)
		,	1
		)
,	rl.Status
,	rl.PONumber
,	rl.POLineNo
,	rl.POLineDueDate
,	rl.PartCode
,	PartDescription = null
,	EngineeringLevel = p.engineering_level
,	@Quantity
,	rl.PackageType
,	Location = case coalesce(p.class, 'N') when 'N' then '' else coalesce((select max(plant) from po_header where po_number =rl.PONumber),pi.primary_location) end
,	Plant = coalesce((select max(plant) from po_header where po_number =rl.PONumber),l.plant)
,	p.gl_account_code
,	pp.gl_account_code
,	SupplierLicensePlate = @SupplierLicensePlate
from
	dbo.ReceiverLines rl
	join @Requirements r
		on rl.ReceiverID = r.ReceiverID
		and rl.PONumber = r.PONumber
		and rl.POLineNo = r.POLineNo
	left join dbo.part p on rl.PartCode = p.part
	left join dbo.part_inventory pi on rl.PartCode = pi.part
	left join dbo.location l on pi.primary_location = l.code
	left join dbo.part_purchasing pp on rl.PartCode = pp.part
where
	rl.ReceiverID = @ReceiverID

select
	@Error = @@Error
,	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return
end
if	@RowCount != 1 begin
	set	@Result = 999999
	RAISERROR ('Error inserting into table %s in procedure %s.  Rows inserted: %d.  Expected rows: 1.', 16, 1, @TableName, @ProcName, @RowCount)
	rollback tran @ProcName
	return
end

set	@ReceiverObjectID = scope_identity()
--- </Insert>

---	<CloseTran AutoCommit=Yes>
if	@TranCount = 0 begin
	commit tran @ProcName
end
---	</CloseTran AutoCommit=Yes>

---	<Return>
set	@Result = 0
return
	@Result
--- </Return>

/*
Example:
Initial queries
{

}

Test syntax
{

set statistics io on
set statistics time on
go

declare
	@Param1 [scalar_data_type]

set	@Param1 = [test_value]

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_ReceivingDock_NewReceiverObjectFromScan
	@Param1 = @Param1
,	@TranDT = @TranDT out
,	@Result = @ProcResult out

set	@Error = @@error

select
	@Error, @ProcReturn, @TranDT, @ProcResult
go

if	@@trancount > 0 begin
	rollback
end
go

set statistics io off
set statistics time off
go

}

Results {
}
*/
GO
