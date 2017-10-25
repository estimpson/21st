SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[usp_InventoryControl_BreakoutRequest]
	@User varchar(5)
,	@BatchFlag smallint
,	@LabelFormat varchar(100)
,	@QtyPerObject decimal(20,6)
,	@Unit varchar(2)
,	@ObjectCount smallint
,	@BreakoutSerialList varchar(max)
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
	@BreakoutSerials table
(	Serial int primary key
)

if	@BatchFlag = 0 begin
	insert
		@BreakoutSerials
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
				dbo.fn_SplitStringToRows(@BreakoutSerialList, ',') fsstr
			where
				convert(int, rtrim(fsstr.Value)) > 0
		)
		and o.std_quantity >= dbo.udf_GetStdQtyFromQty(o.part, @QtyPerObject * @ObjectCount, @Unit)
		and o.type is null
		and o.shipper is null
		and o.status != 'P'
end
else begin
	insert
		@BreakoutSerials
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
				dbo.fn_SplitStringToRows(@BreakoutSerialList, ',') fsstr
			where
				convert(int, rtrim(fsstr.Value)) > 0
		)
		and o.std_quantity >= dbo.udf_GetStdQtyFromQty(o.part, @QtyPerObject * @ObjectCount, @Unit)
		and o.type is null
		and o.shipper is null
		and o.status != 'P'
end

declare
	@results table
(	Operator varchar(5)
,	BatchFlag smallint
,	QtyPerObject numeric(20,6)
,	Unit varchar(2)
,	ObjectCount int
,	BreakoutSerials varchar(max)
,	UserValidationFlag int
,	QtyPerObjectValidationFlag int
,	UnitValidationFlag int
,	ObjectCountValidationFlag int
,	BreakoutSerialValidationFlag int
)

insert
	@results
(	Operator
,	BatchFlag
,	QtyPerObject
,	Unit
,	ObjectCount
,	BreakoutSerials
,	UserValidationFlag
,	QtyPerObjectValidationFlag
,	UnitValidationFlag
,	ObjectCountValidationFlag
,	BreakoutSerialValidationFlag
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
,	QtyPerObject = case when @QtyPerObject > 0 then @QtyPerObject end
,	Unit =
		(	select
				max(dbo.udf_GetAlternateUnit(o.part, @Unit))
			from
				dbo.object o
			where
				o.serial in
					(	select
							ts.Serial
						from
							@BreakoutSerials ts
					)
				and o.std_quantity >= dbo.udf_GetStdQtyFromQty(o.part, @QtyPerObject * @ObjectCount, @Unit)
				and o.type is null
				and o.shipper is null
				and o.status != 'P'
		)
,	ObjectCount = case when @ObjectCount > 0 then @ObjectCount end
,	BreakoutSerials =
		(	select
				Fx.ToList(o.serial)
			from
				dbo.object o
			where
				o.serial in
					(	select
							ts.Serial
						from
							@BreakoutSerials ts
					)
				and o.std_quantity >= dbo.udf_GetStdQtyFromQty(o.part, @QtyPerObject * @ObjectCount, @Unit)
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
,	QtyPerObjectValidationFlag = case when @QtyPerObject > 0 then 1 else -1 end
,	UnitValidationFlag =
		case
			when exists
				(	select
						*
					from
						dbo.object o
					where
						o.serial in
						(	select
								ts.Serial
							from
								@BreakoutSerials ts
						)
						and o.std_quantity >= dbo.udf_GetStdQtyFromQty(o.part, @QtyPerObject * @ObjectCount, @Unit)
						and dbo.udf_GetAlternateUnit (o.part, @Unit) = @Unit
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
						o.serial in
						(	select
								ts.Serial
							from
								@BreakoutSerials ts
						)
						and o.std_quantity >= dbo.udf_GetStdQtyFromQty(o.part, @QtyPerObject * @ObjectCount, @Unit)
						and
						(	dbo.udf_GetAlternateUnit (o.part, @Unit) != @Unit
							or o.shipper is not null
							or o.status = 'P'
						)
				) then 1
			else -1
		end
,	ObjectCountValidationFlag = case when @ObjectCount > 0 then 1 else -1 end
,	BreakoutSerialValidationFlag = coalesce
		(	case
				when exists
					(	select
							*
						from
							dbo.object o
						where
							o.serial in
							(	select
									ts.Serial
								from
									@BreakoutSerials ts
							)
							and o.std_quantity >= dbo.udf_GetStdQtyFromQty(o.part, @QtyPerObject * @ObjectCount, @Unit)
							and dbo.udf_GetAlternateUnit (o.part, @Unit) = @Unit
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
							o.serial in
							(	select
									ts.Serial
								from
									@BreakoutSerials ts
							)
							and o.std_quantity >= dbo.udf_GetStdQtyFromQty(o.part, @QtyPerObject * @ObjectCount, @Unit)
							and
							(	dbo.udf_GetAlternateUnit (o.part, @Unit) != @Unit
								or o.shipper is not null
								or o.status = 'P'
							)
					)
				then 1
			end
		,	(	select
					max
					(	case
							when dbo.udf_GetAlternateUnit (o.part, @Unit) != @Unit then -1
							when o.shipper is not null then -2
							when o.status = 'P' then -3
						end
					)
				from
					dbo.object o
				where
					o.serial  in
					(	select
							ts.Serial
						from
							@BreakoutSerials ts
					)
					and o.std_quantity >= dbo.udf_GetStdQtyFromQty(o.part, @QtyPerObject * @ObjectCount, @Unit)
					and
					(	dbo.udf_GetAlternateUnit (o.part, @Unit) != @Unit
						or o.shipper is null
						or o.status = 'P'
					)
				)
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
											bs.Serial
										from
											@BreakoutSerials bs
									)
								and o.type is null
								and o.shipper is null
								and o.status != 'P'
						)
		 	)
		,	'NOLABEL'
		)
,	r.QtyPerObject
,	r.Unit
,	r.ObjectCount
,	r.BreakoutSerials
,	r.UserValidationFlag
,	LabelFormatValidationFlag = 1
,	r.QtyPerObjectValidationFlag
,	r.UnitValidationFlag
,	r.ObjectCountValidationFlag
,	r.BreakoutSerialValidationFlag
,	UserValidation =
		case r.UserValidationFlag
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
,	QtyPerObjectValidation =
		case r.QtyPerObjectValidationFlag
			when 1 then ''
			else 'Enter qty. greater than zero.'
		end
,	UnitValidation =
		case r.UnitValidationFlag
			when 1 then ''
			else 'Invalid unit for this object''s part.'
		end
,	ObjectCountValidation =
		case r.ObjectCountValidationFlag
			when 1 then ''
			else 'Enter qty. greater than zero.'
		end
,	BreakoutSerialValidation =
		case r.BreakoutSerialValidationFlag
			when 1 then 'Valid serial(s)'
			when -1 then 'One or more objects incompatible with selected unit.'
			when -2 then 'One or more serials staged to a shipper.'
			when -3 then 'One or more serials at outside processor.'
			else 'Invalid serial(s)'
		end
,	BreakoutValidationFlag =
		case when
			r.UserValidationFlag < 1
			or r.QtyPerObjectValidationFlag < 1
			or r.UnitValidationFlag < 1
			or r.ObjectCountValidationFlag < 1
			or r.BreakoutSerialValidationFlag < 1
			then -1
			else 1
		end
,	BreakoutMessage =
		case when
			r.UserValidationFlag < 1
			or r.QtyPerObjectValidationFlag < 1
			or r.UnitValidationFlag < 1
			or r.ObjectCountValidationFlag < 1
			or r.BreakoutSerialValidationFlag < 1
			then 'See validation messages and resolve them to continue.'
			else convert(varchar, r.ObjectCount) + ' objects of ' + convert(varchar, @QtyPerObject) + ' ' + @Unit + ' will be broken out from each object in the list.'
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
,	@LabelFormat varchar(100) = ''
,	@QtyPerObject decimal(20,6) = 1
,	@Unit varchar(2) = 'PC'
,	@ObjectCount smallint = 10
,	@BreakoutSerialList varchar(max) = '1791872,1791901,1791902,1791933,1791934,1791935,1791955,1792049,'

begin transaction Test

declare
	@ProcReturn integer
,	@TranDT datetime
,	@ProcResult integer
,	@Error integer

execute
	@ProcReturn = dbo.usp_InventoryControl_BreakoutRequest
	@User = @User
,	@BatchFlag = @BatchFlag
,	@LabelFormat = @LabelFormat
,	@QtyPerObject = @QtyPerObject
,	@Unit = @Unit
,	@ObjectCount = @ObjectCount
,	@BreakoutSerialList = @BreakoutSerialList
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
