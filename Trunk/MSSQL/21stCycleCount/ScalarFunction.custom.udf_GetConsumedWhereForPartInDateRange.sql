
if	objectproperty(object_id('custom.udf_GetConsumedWhereForPartInDateRange'), 'IsScalarFunction') = 1 begin
	drop function custom.udf_GetConsumedWhereForPartInDateRange
end
go

create function custom.udf_GetConsumedWhereForPartInDateRange
(	@PartConsumed varchar(25)
,	@FromDT datetime
,	@ToDT datetime
)
returns varchar(max)
as
begin
--- <Body>
	declare
		@ConsumedWherePart varchar(max)
	
	set	@ConsumedWherePart = ''
	
	select distinct
		@ConsumedWherePart = @ConsumedWherePart + woh.MachineCode + ','
	from
		dbo.BackflushDetails bd
		join dbo.BackflushHeaders bh
			on bh.BackflushNumber = bd.BackflushNumber
		join dbo.WorkOrderHeaders woh
			on woh.WorkOrderNumber = bh.WorkOrderNumber
	where
		bd.PartConsumed = @PartConsumed
		and bd.RowCreateDT between @FromDT and @ToDT
	
	if	@ConsumedWherePart > '' begin
		set @ConsumedWherePart = left(@ConsumedWherePart, len(@ConsumedWherePart) - 1)
	end
--- </Body>

---	<Return>
	return
		@ConsumedWherePart
end
go

