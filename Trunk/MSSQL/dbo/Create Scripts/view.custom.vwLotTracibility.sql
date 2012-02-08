if	objectproperty(object_id('custom.vwLotTracibility'), 'IsView') = 1 begin
	drop view custom.vwLotTracibility
end
go

Create view [custom].[vwLotTracibility]
as
select	
        PartProduced ,
        SerialProduced ,
        QtyProduced ,
        TranDT ,
        PartConsumed ,
        SerialConsumed ,
        QtyIssue ,
        QtyOverage ,
		WH.MachineCode,
		CustomerCode,
		atCreate.lot
		
from		dbo.BackflushHeaders BH with(nolock)
join		dbo.BackflushDetails BD with(nolock) on BH.BackflushNumber = BD.BackflushNumber
join		dbo.WorkOrderHeaders WH with(nolock) on BH.WorkOrderNumber = WH.WorkOrderNumber
join		dbo.WorkOrderDetails WD with(nolock) on WH.WorkOrderNumber = WD.WorkOrderNumber and WD.Line = BH.WorkOrderDetailLine
left join dbo.audit_trail  atCreate with(nolock)
		on atCreate.type in ('R', 'J', 'A', 'B')
		and atCreate.date_stamp = (select min(date_stamp) from dbo.audit_trail where serial = BD.SerialConsumed)
		and atCreate.serial = BD.SerialConsumed
GO

select	* from custom.vwLotTracibility

