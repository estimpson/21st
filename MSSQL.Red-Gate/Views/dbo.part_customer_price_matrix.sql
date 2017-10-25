SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[part_customer_price_matrix]
as
select
	part = p.part + (select '') --to make not updateable
,	customer = pc.customer + (select '') --to make not updateable
,	code = convert(varchar(10), null)
,	price = pc.blanket_price + (select 0) --to make not updateable
,	qty_break = convert(numeric(20,6), 1)
,	discount = convert(numeric(20,6), null)
,	category = convert(varchar(25), null)
,	alternate_price = pc.blanket_price
from
	dbo.part_customer pc
	join dbo.part p on pc.part = p.part
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE trigger [dbo].[tr_part_customer_price_matrix] on [dbo].[part_customer_price_matrix] instead of insert, update, delete
as
if	1 = 0 begin
	rollback
end
GO
