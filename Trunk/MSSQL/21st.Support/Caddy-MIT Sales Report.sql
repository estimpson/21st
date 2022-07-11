select
	*
from
	dbo.customer c
where
	c.name like '%CADDY%'
	or c.name like '%MIT%'
	or c.customer like '%CADDY%'
	or c.customer like '%MIT%'

select
	*
from
	dbo.shipper s
where
	s.customer in ('MIT', 'PalmDesert')

select
	*
from
	dbo.destination d
where
	d.destination in (
select distinct
	s.destination
from
	dbo.shipper s
where
	s.customer in ('MIT', 'PalmDesert')
) and d.name like '%IRWIN%'

select
	sd.part
,	sd.qty_packed
,	amount = sd.qty_packed * sd.price
,	s.date_shipped
from
	dbo.shipper s
	join dbo.shipper_detail sd
		on sd.shipper = s.id
where
	s.destination in ('TELEIRWIN', 'IRWINSEAT', 'IRWN')
	and s.type is null
	and s.date_shipped > '2019-01-01'