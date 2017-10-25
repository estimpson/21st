SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

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
EXEC sp_addextendedproperty N'SVN_Revision', N'$Rev$', 'SCHEMA', N'custom', 'VIEW', N'vwInventoryByLocation', NULL, NULL
GO
EXEC sp_addextendedproperty N'T_Checksum', N'898295783', 'SCHEMA', N'custom', 'VIEW', N'vwInventoryByLocation', NULL, NULL
GO
