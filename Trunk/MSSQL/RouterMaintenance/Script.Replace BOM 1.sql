
/*
drop table
	bom_sb786_to_wpp234_pre

CREATE TABLE [dbo].[bom_sb786_to_wpp234_pre]
(
[parent_part] VARCHAR(25) NOT NULL,
[part] VARCHAR(25) NOT NULL,
[type] CHAR(1) NOT NULL,
[quantity] NUMERIC(20, 6) NOT NULL,
[unit_measure] VARCHAR(2) NOT NULL,
[reference_no] VARCHAR(50),
[std_qty] NUMERIC(20, 6),
[scrap_factor] NUMERIC(29, 22),
[substitute_part] VARCHAR(25),
[ID] INT NOT NULL,
[LastUser] SYSNAME NOT NULL,
[LastDT] DATETIME
)
go

insert
dbo.bom_sb786_to_wpp234_pre
(	parent_part
,	part
,	type
,	quantity
,	unit_measure
,	reference_no
,	std_qty
,	scrap_factor
,	substitute_part
,	ID
,	LastUser
,	LastDT
)
select
	*
from
	dbo.bill_of_material bom
where
	bom.part = 'SB786'

insert
	dbo.bom_sb786_to_wpp234_pre
(
	parent_part
,	part
,	type
,	quantity
,	unit_measure
,	reference_no
,	std_qty
,	scrap_factor
,	substitute_part
,	ID
,	LastUser
,	LastDT
)	
select
	bom.parent_part
  ,	bom.part
  ,	bom.type
  ,	bom.quantity
  ,	bom.unit_measure
  ,	bom.reference_no
  ,	bom.std_qty
  ,	bom.scrap_factor
  ,	bom.substitute_part
  ,	bom.ID
  ,	bom.LastUser
  ,	bom.LastDT
from
	dbo.bill_of_material bom
where
	bom.part = 'WPP231-28'
*/

begin transaction
go

select
	*
from
	dbo.bill_of_material bom
where
	bom.part = 'SB786'

select
	*
from
	dbo.bill_of_material bom
where
	bom.part = 'WPP231-28'

select
	*
from
	dbo.bill_of_material bom
where
	bom.parent_part = 'SB786'

select
	*
from
	dbo.bill_of_material bom
where
	bom.parent_part = 'WPP231-28'
go

update
	bom
set	bom.part = 'WPP231-28'
,	bom.unit_measure = 'LB'
from
	dbo.bill_of_material_ec bom
where
	bom.part = 'SB786'
	and ID in
		(	select
				bom2.ID
			from
				dbo.bill_of_material bom2
			where
				bom2.part = 'SB786'
		)

insert
	dbo.bill_of_material_ec
(	parent_part
,	part
,	start_datetime
,	date_changed
,	type
,	quantity
,	unit_measure
,	reference_no
,	std_qty
,	scrap_factor
,	substitute_part
)
select
	parent_part = 'WPP231-28'
,	part = 'SB786'
,	start_datetime = getdate()
,	date_changed = getdate()
,	type = 'M'
,	quantity = 1
,	unit_measure = 'LB'
,	reference_no = null
,	std_qty = 1
,	scrap_factor = 1
,	substitute_part = 'Y'
	
go

select
	*
from
	dbo.bill_of_material bom
where
	bom.part = 'SB786'

select
	*
from
	dbo.bill_of_material bom
where
	bom.part = 'WPP231-28'

select
	*
from
	dbo.bill_of_material bom
where
	bom.parent_part = 'SB786'

select
	*
from
	dbo.bill_of_material bom
where
	bom.parent_part = 'WPP231-28'
go

commit
go

