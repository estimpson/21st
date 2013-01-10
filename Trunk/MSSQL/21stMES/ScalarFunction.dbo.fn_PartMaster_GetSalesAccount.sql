
if	objectproperty(object_id('fn_PartMaster_GetSalesAccount'), 'IsScalarFunction') = 1 begin
	drop function fn_PartMaster_GetSalesAccount
end
go

create function fn_PartMaster_GetSalesAccount
(	@PartCode varchar(10)
)
returns varchar(50)
as
begin
--- <Body>
	declare
		@SalesAccount varchar(50)
	
	select
		@SalesAccount = case when p.class = 'M' then pm.gl_account_code else pp.gl_account_code end
	from
		dbo.part p
		left join dbo.part_mfg pm
			on pm.part = p.part
		left join dbo.part_purchasing pp
			on pp.part = p.part
	where
		p.part = @PartCode
--- </Body>
	
---	<Return>
	return
		@SalesAccount
end
go

