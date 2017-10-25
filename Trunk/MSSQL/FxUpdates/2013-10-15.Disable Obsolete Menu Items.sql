update
	mi
set Status = -1
from
	FT.MenuItems mi
where
	mi.MenuText in ('Outside Processing', 'Physical Inventory', 'ASN', 'Machine')

select
	*
from
	FT.MenuItems mi
where
	mi.MenuText in ('Outside Processing', 'Physical Inventory', 'ASN', 'Machine')

select
	*
from
	FT.XMenuItems
where
	MenuText in ('Outside Processing', 'Physical Inventory', 'ASN', 'Machine')
