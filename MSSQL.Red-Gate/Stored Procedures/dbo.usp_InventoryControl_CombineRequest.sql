SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[usp_InventoryControl_CombineRequest]
	@User varchar(5)
,	@BatchFlag smallint
,	@LabelFormat varchar(100)
,	@CombineSerialList varchar(max)
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
	@CombineSerials table
(	Serial int primary key
)

if	@BatchFlag = 0 begin
	insert
		@CombineSerials
	(	Serial
	)
	select top 2
		o.serial
	from
		dbo.object o
	where
		o.serial in
		(	select
				convert(int, rtrim(fsstr.Value))
			from
				dbo.fn_SplitStringToRows(@CombineSerialList, ',') fsstr
			where
				convert(int, rtrim(fsstr.Value)) > 0
		)
		and o.part =
			(	select top 1
					o.part
				from
					dbo.object o
				where
					o.serial in
					(	select
							convert(int, rtrim(fsstr.Value))
						from
							dbo.fn_SplitStringToRows(@CombineSerialList, ',') fsstr
						where
							convert(int, rtrim(fsstr.Value)) > 0
					)
					and o.type is null
					and o.shipper is null
					and o.status != 'P'
				order by
					o.serial
			)
		and o.status =
			(	select top 1
					o.status
				from
					dbo.object o
				where
					o.serial in
					(	select
							convert(int, rtrim(fsstr.Value))
						from
							dbo.fn_SplitStringToRows(@CombineSerialList, ',') fsstr
						where
							convert(int, rtrim(fsstr.Value)) > 0
					)
					and o.type is null
					and o.shipper is null
					and o.status != 'P'
				order by
					o.serial
			)
		and o.type is null
		and o.shipper is null
		and o.status != 'P'
	order by
		o.serial
end
else begin
	insert
		@CombineSerials
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
				dbo.fn_SplitStringToRows(@CombineSerialList, ',') fsstr
			where
				convert(int, rtrim(fsstr.Value)) > 0
		)
		and o.part =
			(	select top 1
					o.part
				from
					dbo.object o
				where
					o.serial in
					(	select
							convert(int, rtrim(fsstr.Value))
						from
							dbo.fn_SplitStringToRows(@CombineSerialList, ',') fsstr
						where
							convert(int, rtrim(fsstr.Value)) > 0
					)
					and o.type is null
					and o.shipper is null
					and o.status != 'P'
				order by
					o.serial
			)
		and o.status =
			(	select top 1
					o.status
				from
					dbo.object o
				where
					o.serial in
					(	select
							convert(int, rtrim(fsstr.Value))
						from
							dbo.fn_SplitStringToRows(@CombineSerialList, ',') fsstr
						where
							convert(int, rtrim(fsstr.Value)) > 0
					)
					and o.type is null
					and o.shipper is null
					and o.status != 'P'
				order by
					o.serial
			)
		and o.type is null
		and o.shipper is null
		and o.status != 'P'
	order by
		o.serial
end

declare
	@results table
(	Operator varchar(5)
,	BatchFlag smallint
,	ObjectCount int
,	CombineSerials varchar(max)
,	UserValidationFlag int
,	CombineSerialValidationFlag int
)

insert
	@results
(	Operator
,	BatchFlag
,	ObjectCount
,	CombineSerials
,	UserValidationFlag
,	CombineSerialValidationFlag
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
							@CombineSerials ts
					)
				and o.type is null
				and o.shipper is null
				and o.status != 'P'
		)
,	CombineSerials =
		(	select
				Fx.ToList(o.serial)
			from
				dbo.object o
			where
				o.serial in
					(	select
							ts.Serial
						from
							@CombineSerials ts
					)
				and o.type is null
				and o.shipper is null
				and o.status != 'P'
		)
,	UserValidationFlag = coalesce
		(	(	select
					1
				from
					dbo.employee e
				where
					e.operator_code = @User
			)
		,	case when @User > '' then -1 + @User else 0 end
		)
,	CombineSerialValidationFlag = coalesce
		(	case
				when
					(	select
							count(*)
						from
							dbo.object o
						where
							o.serial  in
							(	select
									ts.Serial
								from
									@CombineSerials ts
							)
							and o.type is null
							and o.shipper is null
							and o.status != 'P'
					) >= 2
					then 1
				when
					(	select
							count(*)
						from
							dbo.object o
						where
							o.serial  in
							(	select
									ts.Serial
								from
									@CombineSerials ts
							)
							and o.type is null
							and o.shipper is null
							and o.status != 'P'
					) > 0
					then -1
			end
		,	-2
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
											ts.Serial
										from
											@CombineSerials ts
									)
								and o.type is null
								and o.shipper is null
								and o.status != 'P'
						)
		 	)
		,	'NOLABEL'
		)
,	r.CombineSerials
,	r.UserValidationFlag
,	LabelFormatValidationFlag = 1
,	r.CombineSerialValidationFlag
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
,	CombineSerialValidation = case r.CombineSerialValidationFlag
		when 1 then 'Valid serials'
		when -1 then 'Two or more serials must be selected for combine.'
		when -2 then 'Serials must be selected to combine.'
		else 'Invalid serial(s)'
	end
,	CombineValidationFlag =
	case when
		r.UserValidationFlag < 1
		or r.CombineSerialValidationFlag < 1
		then -1
		else 1
	end
,	CombineMessage =
	case when
		r.UserValidationFlag < 1
		or r.CombineSerialValidationFlag < 1
		then 'See validation messages and resolve them to continue.'
		else
			convert(varchar, r.ObjectCount) + ' objects will be combined.'
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
,	@CombineSerial int = 0

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_InventoryControl_CombineRequest
	@User = @User
,	@BatchFlag = @BatchFlag
,	@SuperObjectFlag = @SuperObjectFlag
,	@Location = @Location
,	@PalletSerial = @PalletSerial
,	@CombineSerial = @CombineSerial
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
