
if	objectproperty(object_id('fn_CustomerMaster_GetCustomerSalesrep'), 'IsScalarFunction') = 1 begin
	drop function fn_CustomerMaster_GetCustomerSalesrep
end
go

create function fn_CustomerMaster_GetCustomerSalesrep
(	@CustomerCode varchar(10)
)
returns varchar(10)
as
begin
--- <Body>
	declare
		@Salesrep varchar(10)
	
	select
		@Salesrep = c.salesrep
	from
		dbo.customer c
	where
		c.customer = @CustomerCode
--- </Body>
	
---	<Return>
	return
		@Salesrep
end
go

