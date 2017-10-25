SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[fn_PartCustomer_GetStandardPrice]
(	@PartCode varchar(25)
,	@CustomerCode varchar(10)
,	@Quantity numeric(20,6)
)
returns varchar(10)
as 
begin
--- <Body>
	declare
		@standardPrice numeric(20,6)
	
		select
			@standardPrice = coalesce
			(	case coalesce(pc.type, '')
					when 'C' then
						case c.multiplier
							when '+' then ps.price + c.markup + c.premium
							when '-' then ps.price - c.markup + c.premium
							when '%' then ps.price + (ps.price * c.markup) + c.premium
							when 'x' then ps.price * c.markup + c.premium
						end
					when 'D' then pcpm.price
					when 'B' then pc.blanket_price
				end
			,	ps.price
			)
		from
			dbo.part_customer pc
			left join dbo.part_customer_price_matrix pcpm
				on pcpm.part = pc.part
				and pcpm.customer = pc.customer
				and pcpm.qty_break = coalesce
					(	(	select
								max(qty_break)
							from
								dbo.part_customer_price_matrix
							where
								part = pc.part
								and customer = pc.customer
								and qty_break < @Quantity
						)
					,	(	select
								min(qty_break)
							from
								dbo.part_customer_price_matrix
							where
								part = pc.part
								and customer = pc.customer
						)
					)
			left join dbo.category c
				join dbo.customer c2
					on c2.category = c.code
				on c2.customer = @CustomerCode
			left join dbo.part_standard ps
				on ps.part = @PartCode
		where
			pc.part = @PartCode
			and pc.customer = @CustomerCode
	
--- </Body>
	
---	<Return>
	return
		@standardPrice
end
GO
