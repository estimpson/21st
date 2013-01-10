

if	objectproperty(object_id('fn_Accounting_FiscalWeek'), 'IsScalarFunction') = 1 begin
	drop function fn_Accounting_FiscalWeek
end
go

create function fn_Accounting_FiscalWeek
(	@Date datetime = null
)
returns int
as
begin
--- <Body>
	set	@Date = coalesce
		(	@Date
		,	(	select
		 			max(vgd.CurrentDatetime)
		 		from
		 			dbo.vwGetDate vgd
			)
		)
	
	declare
		@WeekNo int
	
	select
		@WeekNo = datediff(week, p.fiscal_year_begin, @Date)
	from
		dbo.parameters p
--- </Body>

---	<Return>
	return
		@WeekNo
end
go

