SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[fn_Accounting_FiscalWeek]
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
GO
