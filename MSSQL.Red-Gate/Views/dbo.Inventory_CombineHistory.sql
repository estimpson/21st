SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[Inventory_CombineHistory]
as
select
	FromSerial = atCombineFrom.serial
,	TranDT = atCombineFrom.date_stamp
,	FromPartCode = atCombineFrom.part
,	ToSerial = convert(int, atCombineFrom.to_loc)
,	Quantity = atCombineFrom.std_quantity
from
	dbo.audit_trail atCombineFrom
where
	atCombineFrom.type = 'C'
	and atCombineFrom.from_loc = convert(varchar, atCombineFrom.serial)
	and atCombineFrom.to_loc like '%[0-9]%'
	and atCombineFrom.to_loc not like '%[^0-9]%'
GO
