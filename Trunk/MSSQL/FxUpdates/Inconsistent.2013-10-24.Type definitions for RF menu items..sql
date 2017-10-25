--delete td from FT.TypeDefn td where td.TypeTable = 'FT.MenuItems' and td.TypeColumn = 'Type' and td.TypeCode = 3
insert
	FT.TypeDefn
(	TypeGUID
,	TypeTable
,	TypeColumn
,	TypeCode
,	TypeName
,	HelpText
)
select
	TypeGUID = 'DE4B3C7C-5FCC-48BF-858E-DDB5B1A75164'
,	TypeTable = 'FT.MenuItems'
,	TypeColumn = 'Type'
,	TypeCode = 3
,	TypeName = 'RF.App'
,	HelpText = 'A menu item designed to be opened as an icon on RF gun.'
where
	not exists
		(	select
				*
			from
				FT.TypeDefn td
			where
				td.TypeTable = 'FT.MenuItems'
				and td.TypeColumn = 'Type'
				and td.TypeCode = 3
		)

insert
	FT.TypeDefn
(	TypeGUID
,	TypeTable
,	TypeColumn
,	TypeCode
,	TypeName
,	HelpText
)
select
	TypeGUID = '8A3F7C37-550E-4512-8258-0CB82D34E426'
,	TypeTable = 'FT.MenuItems'
,	TypeColumn = 'Type'
,	TypeCode = 4
,	TypeName = 'RF.TabPage'
,	HelpText = 'A menu item designed to be opened as a tab page in an RF application.'
where
	not exists
		(	select
				*
			from
				FT.TypeDefn td
			where
				td.TypeTable = 'FT.MenuItems'
				and td.TypeColumn = 'Type'
				and td.TypeCode = 4
		)

select
	*
from
	FT.TypeDefn td
where
	td.TypeTable = 'FT.MenuItems'
