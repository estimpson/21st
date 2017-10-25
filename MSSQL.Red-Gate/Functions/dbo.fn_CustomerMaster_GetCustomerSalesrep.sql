SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[fn_CustomerMaster_GetCustomerSalesrep]
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
GO
