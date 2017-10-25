
/*
Script Script.Insert.MenuItem.ReportLibraryEdit.sql
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
	MenuItemName = 'ReportLibraryEdit'
,	ItemOwner = 'sys'
,	Status = 0
,	Type = 1
,	MenuText = 'Report Library'
,	MenuIcon = 'Library5!'
,	ObjectClass = 'w_reportlibrary_reportedit'

select
	*
from
	FT.MenuItems mi
where
	MenuItemName = 'ReportLibraryEdit'
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
	MenuID = '64CD04D5-53ED-483A-A9FD-188661BEB5B5'
,	MenuItemName = 'ReportLibraryEdit'
,	ItemOwner = 'sys'
,	Status = 0
,	Type = 1
,	MenuText = 'Report Library'
,	MenuIcon = 'Library5!'
,	ObjectClass = 'w_reportlibrary_reportedit'
where
	not exists
	(	select
			*
		from
			FT.MenuItems mi
		where
			mi.MenuID = '64CD04D5-53ED-483A-A9FD-188661BEB5B5'
	)

insert
	FT.MenuStructure
(	ParentMenuID
,	ChildMenuID
,	Sequence
)
select
	ParentMenuID =
		(	select
				mi.MenuID
			from
				FT.MenuItems mi
			where
				mi.ObjectClass = 'w_setupsadmin_main'
		)
,	ChildMenuID = '64CD04D5-53ED-483A-A9FD-188661BEB5B5'
,	Sequence = coalesce
		(	(	select
					max(ms.Sequence)
				from
					FT.MenuStructure ms
				where
					ms.ParentMenuID =
						(	select
								mi.MenuID
							from
								FT.MenuItems mi
							where
								mi.ObjectClass = 'w_setupsadmin_main'
						)
			)
		,	0
		) + 1
where
	not exists
		(	select
				*
			from
				FT.MenuStructure ms
			where
				ms.ChildMenuID = '64CD04D5-53ED-483A-A9FD-188661BEB5B5'
		)