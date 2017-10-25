
/*
Script Script.Insert.MenuItem.Receiving Dock v2.sql
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
	MenuItemName = 'TMP/Receiving Dock v2'
,	ItemOwner = 'sys'
,	Status = 0
,	Type = 1
,	MenuText = 'Receiving Dock'
,	MenuIcon = 'TruckYellow.ico'
,	ObjectClass = 'w_'

select
	*
from
	FT.MenuItems mi
where
	MenuItemName = 'TMP/Receiving Dock v2'
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
	MenuID = '4b576630-5511-4ea8-986d-026a7b617ca3'
,	MenuItemName = 'TMP/Receiving Dock v2'
,	ItemOwner = 'sys'
,	Status = 0
,	Type = 1
,	MenuText = 'Receiving Dock'
,	MenuIcon = 'TruckYellow.ico'
,	ObjectClass = 'w_receivingdockv2'
where
	not exists
	(	select
			*
		from
			FT.MenuItems mi
		where
			mi.MenuID = '4b576630-5511-4ea8-986d-026a7b617ca3'
	)

insert
	FT.MenuStructure
(	ParentMenuID
,	ChildMenuID
,	Sequence
)
select
	ParentMenuID = 'e489f079-5c16-4a2a-95df-2af994ae990b'
,	ChildMenuID = '4b576630-5511-4ea8-986d-026a7b617ca3'
,	Sequence = 4
where
	not exists
		(	select
				*
			from
				FT.MenuStructure
			where
				ParentMenuID = 'e489f079-5c16-4a2a-95df-2af994ae990b'
				and ChildMenuID = '4b576630-5511-4ea8-986d-026a7b617ca3'
		)
go

