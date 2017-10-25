
/*
Create View.Fx.dbo.Purchasing_PurchaseOrderList.sql
*/

--use Fx
--go

--drop table dbo.Purchasing_PurchaseOrderList
if	objectproperty(object_id('dbo.Purchasing_PurchaseOrderList'), 'IsView') = 1 begin
	drop view dbo.Purchasing_PurchaseOrderList
end
go

create view dbo.Purchasing_PurchaseOrderList
as
select distinct
--	PONumber = coalesce(ph.CUSTOM_BestPO, convert(varchar(50), ph.po_number))
	PONumber = convert(varchar(50), ph.po_number)
,	VendorCode = ph.vendor_code
,	PODate = ph.po_date
,	DueDate = ph.date_due
,	Terms = ph.terms
,	FOB = ph.fob
,	ShipViaScac = ph.ship_via
,	ShipToDestination = ph.ship_to_destination
,	Status = ph.status
,	Type = ph.type
,	Description = ph.description
,	Plant = ph.plant
,	FreightType = ph.freight_type
,	BuyerName = ph.buyer
,	PrintedFlag = ph.printed
,	TotalAmount = ph.total_amount
,	FreightAmount = ph.shipping_fee
,	SalesTax = ph.sales_tax
,	BlanketQty = ph.blanket_orderded_qty
,	BlanketFrequency = ph.blanket_frequency
,	BlanketDuration = ph.blanket_duration
,	BlanketQtyPerRelease = ph.blanket_qty_per_release
,	BlanketPart = ph.blanket_part
,	PurchasePart = coalesce(ph.blanket_part, pd.part_number)
,	VendorPart = coalesce(ph.blanket_vendor_part, pv.vendor_part)
,	Price = ph.price
,	StandardUnit = ph.std_unit
,	ShipType = ph.ship_type
,	Flag = ph.flag
,	ReleaseNo = ph.release_no
,	ReleaseControl = ph.release_control
,	TaxRate = ph.tax_rate
,	ScheduledTime = ph.scheduled_time
,	InternalPONumber = ph.po_number
from
	dbo.po_header ph
	left join dbo.po_detail pd
		on pd.po_number = ph.po_number
	left join dbo.part_vendor pv
		on pv.vendor = ph.vendor_code
		and pv.part = coalesce(ph.blanket_part, pd.part_number)
go

select
	ppol.PONumber
,	ppol.VendorCode
,	ppol.PODate
,	ppol.DueDate
,	ppol.Terms
,	ppol.FOB
,	ppol.ShipViaScac
,	ppol.ShipToDestination
,	ppol.Status
,	ppol.Type
,	ppol.Description
,	ppol.Plant
,	ppol.FreightType
,	ppol.BuyerName
,	ppol.PrintedFlag
,	ppol.TotalAmount
,	ppol.FreightAmount
,	ppol.SalesTax
,	ppol.BlanketQty
,	ppol.BlanketFrequency
,	ppol.BlanketDuration
,	ppol.BlanketQtyPerRelease
,	ppol.BlanketPart
,	ppol.PurchasePart
,	ppol.VendorPart
,	ppol.Price
,	ppol.StandardUnit
,	ppol.ShipType
,	ppol.Flag
,	ppol.ReleaseNo
,	ppol.ReleaseControl
,	ppol.TaxRate
,	ppol.ScheduledTime
,	ppol.InternalPONumber
from
	dbo.Purchasing_PurchaseOrderList ppol
go
