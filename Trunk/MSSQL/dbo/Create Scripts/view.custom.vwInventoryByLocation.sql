if	objectproperty(object_id('custom.vwInventoryByLocation'), 'IsView') = 1 begin
	drop view custom.vwInventoryByLocation
end
go

Create view [custom].[vwInventoryByLocation]
as
select
		Obj.serial,	
        Obj.part Part,
		part.name PartDesc,
		obj.location Location,
		obj.quantity ObjectQuantity,
		obj.unit_measure ObjectUnit,
        obj.user_defined_status ObjectStatus,
		e.name Employee,
		Obj.last_time LastTime,
		Obj.Lot Lot
       
		
from		dbo.Object Obj with(nolock)
join		dbo.part Part with(nolock) on Obj.part = Part.part
join		dbo.employee e with(nolock) on Obj.operator = e.operator_code

GO

select	*
from		custom.vwInventoryByLocation
