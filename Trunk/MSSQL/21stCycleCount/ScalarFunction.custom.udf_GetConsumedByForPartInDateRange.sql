
if	objectproperty(object_id('custom.udf_GetConsumedByForPartInDateRange'), 'IsScalarFunction') = 1 begin
	drop function custom.udf_GetConsumedByForPartInDateRange
end
go

create function custom.udf_GetConsumedByForPartInDateRange
(	@PartConsumed varchar(25)
,	@FromDT datetime
,	@ToDT datetime
)
returns varchar(max)
as
begin
--- <Body>
	declare
		@ConsumedByPart varchar(max)
	
	set	@ConsumedByPart = ''
	
	select distinct
		@ConsumedByPart = @ConsumedByPart + bh.PartProduced + ','
	from
		dbo.BackflushDetails bd
		join dbo.BackflushHeaders bh
			on bh.BackflushNumber = bd.BackflushNumber
	where
		bd.PartConsumed = @PartConsumed
		and bd.RowCreateDT between @FromDT and @ToDT
	
	if	@ConsumedByPart > '' begin
		set @ConsumedByPart = left(@ConsumedByPart, len(@ConsumedByPart) - 1)
	end
--- </Body>

---	<Return>
	return
		@ConsumedByPart
end
go

