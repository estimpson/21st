
/*
Script Script.Insert.MenuItem.Shipping_ExpediteCodes.sql
*/

--use Fx
--go

/*
insert
	FT.MenuItems
(	MenuItemName
,	ItemOwner
,	Status
,	Type
,	MenuText
,	MenuIcon
,	ObjectClass
)
select
	MenuItemName = 'Shipping/ExpediteCodes'
,	ItemOwner = 'sys'
,	Status = 0
,	Type = 1
,	MenuText = 'Expedite Codes'
,	MenuIcon = 'expedite_16.bmp'
,	ObjectClass = 'w_shipping_expeditecodes'

select
	*
from
	FT.MenuItems mi
where
	MenuItemName = 'Shipping/ExpediteCodes'
*/
insert
	FT.MenuItems
(	MenuID
,	MenuItemName
,	ItemOwner
,	Status
,	Type
,	MenuText
,	MenuIcon
,	ObjectClass
)
select
	MenuID = 'B85BBCC1-2B57-433A-891C-06B2A1DDC061'
,	MenuItemName = 'Shipping/ExpediteCodes'
,	ItemOwner = 'sys'
,	Status = 0
,	Type = 1
,	MenuText = 'Expedite Codes'
,	MenuIcon = 'expedite_16.bmp'
,	ObjectClass = 'w_shipping_expeditecodes'
where
	not exists
	(	select
			*
		from
			FT.MenuItems mi
		where
			mi.MenuID = 'B85BBCC1-2B57-433A-891C-06B2A1DDC061'
	)

insert
	FT.MenuStructure
(	ParentMenuID
,	ChildMenuID
,	Sequence
)
select
	ParentMenuID = mi.MenuID
,	ChildMenuID = 'B85BBCC1-2B57-433A-891C-06B2A1DDC061'
,	Sequence =
		coalesce
		(	(	select
					max(ms.Sequence) + 1
				from
					FT.MenuStructure ms
				where
					ms.ParentMenuID = mi.MenuID
			)
		,	1
		)
from
	FT.MenuItems mi
where
	mi.MenuItemName = 'TMO/Shipping'
	and not exists
		(	select
				*
			from
				FT.MenuStructure ms
			where
				ms.ParentMenuID = mi.MenuID
				and ms.ChildMenuID = 'B85BBCC1-2B57-433A-891C-06B2A1DDC061'
		)