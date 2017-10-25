SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[usp_InventoryControl_RelabelRequest]
	@User varchar(5)
,	@BatchFlag smallint
,	@LabelFormat varchar(100)
,	@RelabelSerialList varchar(max)
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

---	</ArgumentValidation>

--- <Body>
declare
	@RelabelSerials table
(	Serial int primary key
)

insert
	@RelabelSerials
(	Serial
)
select
	o.serial
from
	dbo.object o
where
	o.serial in
	(	select
			convert(int, rtrim(fsstr.Value))
		from
			dbo.fn_SplitStringToRows(@RelabelSerialList, ',') fsstr
		where
			convert(int, rtrim(fsstr.Value)) > 0
	)

if	@@ROWCOUNT > 1 begin
	set @BatchFlag = 1
end
else begin
	set @BatchFlag = 0
end

declare
	@results table
(	Operator varchar(5)
,	BatchFlag smallint
,	SuperObjectFlag smallint
,	Location varchar(10)
,	PalletSerial int
,	ObjectCount int
,	RelabelSerials varchar(max)
,	UserValidationFlag int
,	LocationValidationFlag int
,	PalletSerialValidationFlag int
,	RelabelSerialValidationFlag int
)

insert
	@results
(	Operator
,	BatchFlag
,	ObjectCount
,	RelabelSerials
,	UserValidationFlag
,	RelabelSerialValidationFlag
)
select
	Operator =
		(	select
				e.operator_code
			from
				dbo.employee e
			where
				e.operator_code = @User
		)
,	BatchFlag = @BatchFlag
,	ObjectCount =
		(	select
				count(*)
			from
				dbo.object o
			where
				o.serial in
					(	select
							ts.Serial
						from
							@RelabelSerials ts
					)
		)
,	RelabelSerials =
		(	select
				Fx.ToList(o.serial)
			from
				dbo.object o
			where
				o.serial in
					(	select
							ts.Serial
						from
							@RelabelSerials ts
					)
		)
,	UserValidation = coalesce
		(	(	select
					1
				from
					dbo.employee e
				where
					e.operator_code = @User
			)
		,	case when @User > '' then -1 + @User else 0 end
		)
,	RelabelSerialValidation = coalesce
		(	case
				when exists
					(	select
							*
						from
							dbo.object o
						where
							o.serial  in
							(	select
									ts.Serial
								from
									@RelabelSerials ts
							)
					)
				then 1
			end
		,	0
		)

select
	r.Operator
,	r.BatchFlag
,	LabelFomat = coalesce
		(	(	select
					rl.name
				from
					dbo.report_library rl
				where
					rl.report = 'Label'
					and rl.name = @LabelFormat
			)
		,	(	select
		 			pInv.label_format
		 		from
		 			dbo.part_inventory pInv
				where
					pInv.part =
						(	select
								min(o.part)
							from
								dbo.object o
							where
								o.serial in
									(	select
											rs.Serial
										from
											@RelabelSerials rs
									)
								and o.type is null
								and o.shipper is null
								and o.status != 'P'
						)
		 	)
		,	'NOLABEL'
		)
,	r.RelabelSerials
,	UserValidationFlag
,	LabelFormatValidationFlag = 1
,	r.RelabelSerialValidationFlag
,	UserValidation = case r.UserValidationFlag
		when 1 then
			(	select
					e.name
				from
					dbo.employee e
				where
					e.operator_code = r.Operator
			)
		when 0 then 'Login required'
		else 'Invalid user'
	end
,	LabelFormatValidation = ''
,	RelabelSerialValidation = case r.RelabelSerialValidationFlag
		when 1 then 'Valid serial(s)'
		else 'Invalid serial(s)'
	end
,	RelabelValidationFlag =
	case when
		r.UserValidationFlag < 1
		or r.RelabelSerialValidationFlag < 1
		then -1
		else 1
	end
,	RelabelMessage =
	case when
		r.UserValidationFlag < 1
		or r.RelabelSerialValidationFlag < 1
		then 'See validation messages and resolve them to continue.'
		else
			convert(varchar, r.ObjectCount) + ' objects will be relabeled.'
	end
from
	@results r

--- </Body>

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
	@User varchar(5) = 'EES'
,	@BatchFlag smallint = 0
,	@SuperObjectFlag smallint = 0
,	@Location varchar(10) = ''
,	@PalletSerial int = 0
,	@RelabelSerial int = 0

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_InventoryControl_RelabelRequest
	@User = @User
,	@BatchFlag = @BatchFlag
,	@SuperObjectFlag = @SuperObjectFlag
,	@Location = @Location
,	@PalletSerial = @PalletSerial
,	@RelabelSerial = @RelabelSerial
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
