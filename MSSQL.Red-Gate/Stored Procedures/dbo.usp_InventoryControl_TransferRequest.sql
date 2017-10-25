SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[usp_InventoryControl_TransferRequest]
	@User varchar(5)
,	@BatchFlag smallint
,	@SuperObjectFlag smallint
,	@Location varchar(10)
,	@PalletSerial int
,	@TransferSerialList varchar(max)
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
	@transferSerials table
(	Serial int primary key
)

if	@BatchFlag = 0 begin
	insert
		@transferSerials
	(	Serial
	)
	select top 1
		o.serial
	from
		dbo.object o
	where
		o.serial in
		(	select
				convert(int, rtrim(fsstr.Value))
			from
				dbo.fn_SplitStringToRows(@TransferSerialList, ',') fsstr
			where
				convert(int, rtrim(fsstr.Value)) > 0
		)
		and
		(	(	@SuperObjectFlag = 1
				and coalesce(o.parent_serial, -1) != @PalletSerial
			)
			or
			(	@SuperObjectFlag = 0
				and o.location != @Location
			)
		)
		and o.type is null
		and o.shipper is null
		and o.status != 'P'
end
else begin
	insert
		@transferSerials
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
				dbo.fn_SplitStringToRows(@TransferSerialList, ',') fsstr
			where
				convert(int, rtrim(fsstr.Value)) > 0
		)
		and
		(	(	@SuperObjectFlag = 1
				and coalesce(o.parent_serial, -1) != @PalletSerial
			)
			or
			(	@SuperObjectFlag = 0
				and o.location != @Location
			)
		)
		and o.type is null
		and o.shipper is null
		and o.status != 'P'
end

declare
	@results table
(	Operator varchar(5)
,	BatchFlag smallint
,	SuperObjectFlag smallint
,	Location varchar(10)
,	PalletSerial int
,	ObjectCount int
,	TransferSerials varchar(max)
,	UserValidationFlag int
,	LocationValidationFlag int
,	PalletSerialValidationFlag int
,	TransferSerialValidationFlag int
)

insert
	@results
(	Operator
,	BatchFlag
,	SuperObjectFlag
,	Location
,	PalletSerial
,	ObjectCount
,	TransferSerials
,	UserValidationFlag
,	LocationValidationFlag
,	PalletSerialValidationFlag
,	TransferSerialValidationFlag
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
,	SuperObjectFlag = @SuperObjectFlag
,	Location =
		(	select
				l.code
			from
				dbo.location l
			where
				l.code = @Location
		)
,	PalletSerial =
		(	select
				o.serial
			from
				dbo.object o
			where
				o.serial = @PalletSerial
				and o.type = 'S'
				and o.shipper is null
		)
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
							@transferSerials ts
					)
				and
				(	(	@SuperObjectFlag = 1
						and coalesce(o.parent_serial, -1) != @PalletSerial
					)
					or
					(	@SuperObjectFlag = 0
						and o.location != @Location
					)
				)
				and o.type is null
				and o.shipper is null
				and o.status != 'P'
		)
,	TransferSerials =
		(	select
				Fx.ToList(o.serial)
			from
				dbo.object o
			where
				o.serial in
					(	select
							ts.Serial
						from
							@transferSerials ts
					)
				and
				(	(	@SuperObjectFlag = 1
						and coalesce(o.parent_serial, -1) != @PalletSerial
					)
					or
					(	@SuperObjectFlag = 0
						and o.location != @Location
					)
				)
				and o.type is null
				and o.shipper is null
				and o.status != 'P'
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
,	LocationValidation =
		case when @SuperObjectFlag = 0 then	coalesce
			(	(	select
						1
					from
						dbo.location l
					where
						l.code = @Location
		 		)
			,	case when @Location > '' then -1 else 0 end
			,	0
			)
		end
,	PalletSerialValidation = 
		case when @SuperObjectFlag = 1 then	coalesce
			(	(	select
						1
					from
						dbo.object o
					where
						o.serial = @PalletSerial
						and o.type = 'S'
						and o.shipper is null
		 		)
			,	case when @PalletSerial > 0 then -1 else 0 end
			,	0
			)
		end
,	TransferSerialValidation = coalesce
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
									@transferSerials ts
							)
							and
							(	(	@SuperObjectFlag = 1
									and coalesce(o.parent_serial, -1) != @PalletSerial
								)
								or
								(	@SuperObjectFlag = 0
									and o.location != @Location
								)
							)
							and o.type is null
							and o.shipper is null
							and o.status != 'P'
					) and
					not exists
					(	select
							*
						from
							dbo.object o
						where
							o.serial  in
							(	select
									ts.Serial
								from
									@transferSerials ts
							)
							and
							(	(	@SuperObjectFlag = 1
									and coalesce(o.parent_serial, -1) != @PalletSerial
								)
								or
								(	@SuperObjectFlag = 0
									and o.location != @Location
								)
							)
							and
							(	o.shipper is not null
								or o.status = 'P'
							)
					)
				then 1
			end
		,	(	select
					max
					(	case
							when o.shipper is not null then -1
							when o.status = 'P' then -2
						end
					)
				from
					dbo.object o
				where
					o.serial  in
					(	select
							ts.Serial
						from
							@transferSerials ts
					)
					and
					(	(	@SuperObjectFlag = 1
							and coalesce(o.parent_serial, -1) != @PalletSerial
						)
						or
						(	@SuperObjectFlag = 0
							and o.location != @Location
						)
					)
					and
					(	o.shipper is null
						or o.status = 'P'
					)
				)
		,	0
		)

select
	r.Operator
,	r.BatchFlag
,	r.SuperObjectFlag
,	r.Location
,	r.PalletSerial
,	r.TransferSerials
,	UserValidationFlag
,	LocationValidationFlag
,	PalletSerialValidationFlag
,	TransferSerialValidationFlag
,	case r.UserValidationFlag
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
,	case
		when
			coalesce(r.LocationValidationFlag, 0) = 1
			or SuperObjectFlag = 1
			then ''
		when
			r.LocationValidationFlag = 0
			and r.SuperObjectFlag = 0 then 'Location  required'
		else 'Invalid location'
	end
,	case
		when
			coalesce(r.PalletSerialValidationFlag, 0) = 1
			or SuperObjectFlag = 0
			then ''
		when
			r.PalletSerialValidationFlag = 0
			and r.SuperObjectFlag = 1 then 'Pallet  required'
		else 'Invalid pallet'
	end
,	case r.TransferSerialValidationFlag
		when 1 then 'Valid serial(s)'
		when -1 then 'One or more serials staged to a shipper.'
		when -2 then 'One or more serials at outside processor.'
		else 'Invalid serial(s)'
	end
,	TransferValidationFlag =
	case when
		r.UserValidationFlag < 1
		or
		(	coalesce(r.LocationValidationFlag, 0) < 1
			and r.SuperObjectFlag = 0
		)
		or
		(	coalesce(r.PalletSerialValidationFlag, 0) < 1
			and r.SuperObjectFlag = 1
		)
		or r.TransferSerialValidationFlag < 1
		then -1
		else 1
	end
,	TransferMessage =
	case when
		r.UserValidationFlag < 1
		or
		(	coalesce(r.LocationValidationFlag, 0) < 1
			and r.SuperObjectFlag = 0
		)
		or
		(	coalesce(r.PalletSerialValidationFlag, 0) < 1
			and r.SuperObjectFlag = 1
		)
		or r.TransferSerialValidationFlag < 1
		then 'See validation messages and resolve them to continue.'
		else
			convert(varchar, r.ObjectCount) + ' objects will be transfered to '
				+
					case
						when r.SuperObjectFlag = 0 then r.Location
						else convert(varchar, r.PalletSerial)
					end
				+ '.'
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
,	@TransferSerial int = 0

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_InventoryControl_TransferRequest
	@User = @User
,	@BatchFlag = @BatchFlag
,	@SuperObjectFlag = @SuperObjectFlag
,	@Location = @Location
,	@PalletSerial = @PalletSerial
,	@TransferSerial = @TransferSerial
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
