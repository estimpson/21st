
/*
Create View.Fx.FT.MenuUserAccess.sql
*/

--use Fx
--go

--drop table FT.MenuUserAccess
if	objectproperty(object_id('FT.MenuUserAccess'), 'IsView') = 1 begin
	drop view FT.MenuUserAccess
end
go

create view FT.MenuUserAccess
as
select
	xmi.MenuID
,	ApplicationName = mi.MenuItemName
,	xmi.MenuItemName
,	xmi.MenuIcon
,	xmi.MenuText
,	xmi.ObjectClass
,	xmi.ObjectType
,	xmi.Level
,	xmi.Sequence
,	xmi.Chain
,	u.OperatorCode
,	UserAccess = case when sa.Type = 0 then 1 else 0 end
from
	FT.XMenuItems xmi
	cross join FT.Users u
	left join FT.SecurityAccess sa
		on sa.ResourceID = xmi.MenuID
		and sa.SecurityID = u.UserID
	join FT.MenuItems mi
		on mi.MenuID = xmi.TopMenuID
go

select
	*
from
	FT.MenuUserAccess
where
	MenuID = 'B9D0C182-6D53-474E-B5C3-29246E3117D1'
go

