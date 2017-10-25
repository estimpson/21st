
/*
Create view Fx.custom.MES_SiloInventory
*/

--use Fx
--go

--drop table custom.MES_SiloInventory
if	objectproperty(object_id('custom.MES_SiloInventory'), 'IsView') = 1 begin
	drop view custom.MES_SiloInventory
end
go

create view custom.MES_SiloInventory
as
select
	Silo = l.code
,	Active = case when l.sequence = 1 then 1 else 0 end
,	Serial = o.serial
,	Part = o.part
,	Quantity = o.std_quantity
,	DateReceived = (select min (date_stamp) from dbo.audit_trail where serial = o.serial and type = 'R')
,	ReceivedQty = (select min (std_quantity) from dbo.audit_trail where serial = o.serial and type = 'R')
from
	dbo.location l
	left join dbo.object o
		on o.location = l.code
where
	l.code like 'SILO%'
go

select
	msi.Silo
,	msi.Active
,	msi.Serial
,	msi.Part
,	msi.Quantity
,	msi.DateReceived
,	msi.ReceivedQty
from
	custom.MES_SiloInventory msi
go
