SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[REPORT_Best1PiecePrice]
as
select	Part = part,
	Price = min(alternate_price)
from	part_customer_price_matrix
where	qty_break = 1
group by
	part

GO
