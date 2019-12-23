begin transaction
go
exec dbo.msp_reconcile_shipper @shipper = 47384 -- int

exec dbo.msp_shipout
	@shipper = 47384
,	@invdate = null


select
	*
from
	dbo.shipper s
	join dbo.shipper_detail sd
		on sd.shipper = s.id
where
	s.id = 47384

commit
go
