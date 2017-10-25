alter trigger dbo.tr_bill_of_material_ec_u
on [dbo].[bill_of_material_ec] instead of update
as
set nocount on
declare
	@tranDT datetime

set	@tranDT = getdate()

--	Create new records...

update
	dbo.bill_of_material_ec
set
	end_datetime = @tranDT
,	LastUser = suser_sname()
,	LastDT = @tranDT
where
	ID in (select ID from deleted where @tranDT between start_datetime and coalesce(end_datetime, @tranDT))

insert
	dbo.bill_of_material_ec
(	parent_part
,   part
,   start_datetime
,   end_datetime
,   type
,   quantity
,   unit_measure
,   reference_no
,   std_qty
,   scrap_factor
,   engineering_level
,   operator
,   substitute_part
,   date_changed
,   note
)
select
	parent_part
,   part
,   start_datetime = @tranDT
,   Null
,   type
,   quantity
,   unit_measure
,   reference_no
,   std_qty = coalesce(dbo.udf_GetStdQtyFromQty(part, quantity, unit_measure), std_qty)
,   scrap_factor
,   engineering_level
,   operator
,   substitute_part
,   date_changed
,   note
from
	inserted
where
	@tranDT between start_datetime and coalesce(end_datetime, @tranDT)

--	End old records.
update
	dbo.bill_of_material_ec
set
	end_datetime = @tranDT
,	LastUser = suser_sname()
,	LastDT = @tranDT
where
	ID in (select ID from deleted where @tranDT between start_datetime and coalesce(end_datetime, @tranDT))


GO
