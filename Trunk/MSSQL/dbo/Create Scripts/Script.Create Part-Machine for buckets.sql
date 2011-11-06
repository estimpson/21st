insert
	dbo.part_machine
select
	p.part
,   pm.machine
,   pm.sequence
,   pm.mfg_lot_size
,   pm.process_id
,   pm.parts_per_cycle
,   pm.parts_per_hour
,   pm.cycle_unit
,   pm.cycle_time
,   pm.overlap_type
,   pm.overlap_time
,   pm.labor_code
,   pm.activity
,   pm.setup_time
,   pm.crew_size
from
	dbo.part_machine pm
	join dbo.part p
		on p.part like left(pm.part, 6) + '%' 
	left join dbo.part_machine pm2
		on pm.part = p.part
where
	pm.part like '1200[12][901]%'
	and pm2.part is null