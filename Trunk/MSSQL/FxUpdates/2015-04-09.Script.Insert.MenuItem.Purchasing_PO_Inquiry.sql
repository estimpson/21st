
/*
Script Script.Insert.MenuItem.Purchasing_PO_Inquiry.sql
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
	MenuItemName = 'Purchasing/PO_Inquiry'
,	ItemOwner = 'sys'
,	Status = 0
,	Type = 1
,	MenuText = 'Purchase Order Inquiry'
,	MenuIcon = 'EditDataTabular!'
,	ObjectClass = 'w_purchasing_poinquiry'

select
	*
from
	FT.MenuItems mi
where
	MenuItemName = 'Purchasing/PO_Inquiry'
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
	MenuID = 'E86F3DC0-D6F0-4F86-B693-DFAB5B97263A'
,	MenuItemName = 'Purchasing/PO_Inquiry'
,	ItemOwner = 'sys'
,	Status = 0
,	Type = 1
,	MenuText = 'Purchase Order Inquiry'
,	MenuIcon = 'EditDataTabular!'
,	ObjectClass = 'w_purchasing_poinquiry'
where
	not exists
	(	select
			*
		from
			FT.MenuItems mi
		where
			mi.MenuID = 'E86F3DC0-D6F0-4F86-B693-DFAB5B97263A'
	)
go

/*
delete
	ms
from
	FT.MenuStructure ms
where
	ms.ParentMenuID = 'E489F079-5C16-4A2A-95DF-2AF994AE990B'
	and ChildMenuID = 'E86F3DC0-D6F0-4F86-B693-DFAB5B97263A'
*/

insert
	FT.MenuStructure
(	ParentMenuID
,	ChildMenuID
,	Sequence
)
select
	ParentMenuID = 'E489F079-5C16-4A2A-95DF-2AF994AE990B'
,	ChildMenuID = 'E86F3DC0-D6F0-4F86-B693-DFAB5B97263A'
,	Sequence =
		(	select
				ms.Sequence + .1
			from
				FT.MenuStructure ms
			where
				ms.ParentMenuID = 'E489F079-5C16-4A2A-95DF-2AF994AE990B'
				and ms.ChildMenuID = '88211A9B-AEB4-4612-8A5D-2CE810F0D7FB'
		)
where
	not exists
		(	select
				*
			from
				FT.MenuStructure ms
			where
				ms.ChildMenuID = 'E86F3DC0-D6F0-4F86-B693-DFAB5B97263A'
		)