update
	mi
set	MenuText = 'Factory Explorer'
,	MenuIcon = 'FT.ico'
from
	FT.MenuItems mi
where
	mi.MenuItemName = 'Factory Explorer - [FX]'

select
	*
from
	FT.MenuItems mi
