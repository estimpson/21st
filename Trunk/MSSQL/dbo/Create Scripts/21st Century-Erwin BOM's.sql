
/*
select	bom.parent_part, bom.part, part.name
from	dbo.bill_of_material bom
	join part on bom.part = part.part
where	bom.parent_part like '121121%'

select	bom.parent_part, bom.part, part.name
from	dbo.bill_of_material bom
	join part on bom.part = part.part
where	parent_part like '121721%'

select	bom.parent_part, bom.part, part.name
from	dbo.bill_of_material bom
	join part on bom.part = part.part
where	parent_part like '123121%'

select	*
from	dbo.part
where	part like '121121%'
*/

begin tran
alter table dbo.bill_of_material_ec disable trigger all

--Colors of standard [quiet rise] full fold, 3/4 fold, 1/2 fold in 19, 20, and 21 inch.
insert	dbo.bill_of_material_ec
(	parent_part,
	part,
	start_datetime,
	type,
	quantity,
	unit_measure,
	reference_no,
	std_qty,
	scrap_factor,
	engineering_level,
	operator,
	substitute_part,
	date_changed,
	note)
select	parent_part = seatcolor.part,
	part =
	case	when bom.part = '120021B' then '1200' + substring(seatcolor.part, 5, 5)
		when bom.part = '1201B' then '1201' + substring(seatcolor.part, 7, 3)
		when bom.part = '1226B' then '1226' + substring(seatcolor.part, 7, 3)
		else bom.part
	end,
	--bom.parent_part,
	start_datetime = getdate(),
	--description = coalesce(component.name, 'UNDEFINED'),
	bom.type,
	bom.quantity,
	bom.unit_measure,
	bom.reference_no,
	bom.std_qty,
	bom.scrap_factor,
	bom.engineering_level,
	bom.operator,
	bom.substitute_part,
	date_changed = getdate(),
	bom.note
from	dbo.part seatcolor
	join dbo.bill_of_material_ec bom on getdate() between coalesce(bom.start_datetime, getdate()) and coalesce(bom.end_datetime, getdate()) and
		seatcolor.part != bom.parent_part and
		(	seatcolor.part = left(bom.parent_part, 4) + '19' + substring(seatcolor.part, 7, 3) or
			seatcolor.part = left(bom.parent_part, 4) + '20' + substring(seatcolor.part, 7, 3) or
			seatcolor.part = left(bom.parent_part, 6) + substring(seatcolor.part, 7, 3) or
			1 = 0)
	left join part component on
		case	when bom.part = '120021B' then '1200' + substring(seatcolor.part, 5, 5)
			when bom.part = '1201B' then '1201' + substring(seatcolor.part, 7, 3)
			when bom.part = '1226B' then '1226' + substring(seatcolor.part, 7, 3)
			else bom.part
		end = component.part
where	(	seatcolor.part like '1211[12][019]%' or
		seatcolor.part like '1217[12][019]%' or
		seatcolor.part like '1231[12][019]%' or
		seatcolor.part like '1262[12][019]%' or
		seatcolor.part like '1263[12][019]%' or
		seatcolor.part like '1264[12][019]%' or
		1 = 0) and
	seatcolor.part not like '%-%' and
	seatcolor.part not like '%1BF'
order by
	1, 2

insert	dbo.part_machine	
(	part,
	machine,
	sequence,
	mfg_lot_size,
	process_id,
	parts_per_cycle,
	parts_per_hour,
	cycle_unit,
	cycle_time,
	overlap_type,
	overlap_time,
	labor_code,
	activity,
	setup_time,
	crew_size)
select	part = seatcolor.part,
	machine = pm.machine,
	sequence = pm.sequence,
	mfg_lot_size = pm.mfg_lot_size,
	process_id = pm.process_id,
	parts_per_cycle = pm.parts_per_cycle,
	parts_per_hour = pm.parts_per_hour,
	cycle_unit = pm.cycle_unit,
	cycle_time = pm.cycle_time,
	overlap_type = pm.overlap_type,
	overlap_time = pm.overlap_time,
	labor_code = pm.labor_code,
	activity = pm.activity,
	setup_time = pm.setup_time,
	crew_size = pm.crew_size
from	dbo.part seatcolor
	join dbo.part_machine pm on seatcolor.part != pm.part and
		(	left(seatcolor.part, 6) = left(pm.part, 4) + '19' or
			left(seatcolor.part, 6) = left(pm.part, 4) + '20' or
			left(seatcolor.part, 6) = left(pm.part, 6) or
			1 = 0)
where	(	seatcolor.part like '1211[12][019]%' or
		seatcolor.part like '1217[12][019]%' or
		seatcolor.part like '1231[12][019]%' or
		seatcolor.part like '1262[12][019]%' or
		seatcolor.part like '1263[12][019]%' or
		seatcolor.part like '1264[12][019]%' or
		1 = 0) and
	seatcolor.part not like '%-%' and
	seatcolor.part not like '%1BF'
order by
	1, 2

insert	dbo.activity_router
(	parent_part,
	sequence,
	code,
	part,
	notes,
	labor,
	material,
	cost_bill,
	group_location,
	process,
	doc1,
	doc2,
	doc3,
	doc4,
	cost,
	price,
	cost_price_factor,
	time_stamp)
select	parent_part = seatcolor.part,
	sequence = pa.sequence,
	code = pa.code,
	part = seatcolor.part,
	notes = pa.notes,
	labor = pa.labor,
	material = pa.material,
	cost_bill = pa.cost_bill,
	group_location = pa.group_location,
	process = pa.process,
	doc1 = pa.doc1,
	doc2 = pa.doc2,
	doc3 = pa.doc3,
	doc4 = pa.doc4,
	cost = pa.cost,
	price = pa.price,
	cost_price_factor = pa.cost_price_factor,
	time_stamp = pa.time_stamp
from	dbo.part seatcolor
	join dbo.activity_router pa on seatcolor.part != pa.part and
		(	left(seatcolor.part, 6) = left(pa.part, 4) + '19' or
			left(seatcolor.part, 6) = left(pa.part, 4) + '20' or
			left(seatcolor.part, 6) = left(pa.part, 6) or
			1 = 0)
where	(	seatcolor.part like '1211[12][019]%' or
		seatcolor.part like '1217[12][019]%' or
		seatcolor.part like '1231[12][019]%' or
		seatcolor.part like '1262[12][019]%' or
		seatcolor.part like '1263[12][019]%' or
		seatcolor.part like '1264[12][019]%' or
		1 = 0) and
	seatcolor.part not like '%-%' and
	seatcolor.part not like '%1BF'
order by
	1, 2

--Seat wide, long right, long left full fold, 3/4 fold, 1/2 fold.
insert	dbo.bill_of_material_ec
(	parent_part,
	part,
	start_datetime,
	type,
	quantity,
	unit_measure,
	reference_no,
	std_qty,
	scrap_factor,
	engineering_level,
	operator,
	substitute_part,
	date_changed,
	note)
select	parent_part = seatcolor.part,
	part =
	case	when left (bom.part,4) = '1201' and substring (seatcolor.part, 5, 2) in ('SW', 'LR') then '1201SW' + substring(bom.parent_part, 7, 3)
		when left (bom.part,4) = '1226' and substring (seatcolor.part, 5, 2) in ('SW', 'RR')  then '1226SW' + substring(bom.parent_part, 7, 3)
		else bom.part
	end,
	--bom.parent_part,
	start_datetime = getdate(),
	--description = coalesce(component.name, 'UNDEFINED'),
	bom.type,
	bom.quantity,
	bom.unit_measure,
	bom.reference_no,
	bom.std_qty,
	bom.scrap_factor,
	bom.engineering_level,
	bom.operator,
	bom.substitute_part,
	date_changed = getdate(),
	bom.note
from	dbo.part seatcolor
	join dbo.bill_of_material_ec bom on getdate() between coalesce(bom.start_datetime, getdate()) and coalesce(bom.end_datetime, getdate()) and
		seatcolor.part != bom.parent_part and
		(	seatcolor.part = left(bom.parent_part, 4) + 'SW' + substring(bom.parent_part, 5, 5) or
			seatcolor.part = left(bom.parent_part, 4) + 'LR' + substring(bom.parent_part, 5, 5) or
			seatcolor.part = left(bom.parent_part, 4) + 'RR' + substring(bom.parent_part, 5, 5))
	left join part component on
		case	when left (bom.part,4) = '1201' and substring (seatcolor.part, 5, 2) in ('SW', 'LR') then '1201SW' + substring(bom.parent_part, 7, 3)
			when left (bom.part,4) = '1226' and substring (seatcolor.part, 5, 2) in ('SW', 'RR')  then '1226SW' + substring(bom.parent_part, 7, 3)
			else bom.part
		end = component.part
where	(	seatcolor.part like '1211[LR]R%' or
		seatcolor.part like '1217[LR]R%' or
		seatcolor.part like '1231[LR]R%' or
		seatcolor.part like '1211SW%' or
		seatcolor.part like '1217SW%' or
		seatcolor.part like '1231SW%' or
		seatcolor.part like '1262[LR]R%' or
		seatcolor.part like '1263[LR]R%' or
		seatcolor.part like '1264[LR]R%' or
		seatcolor.part like '1262SW%' or
		seatcolor.part like '1263SW%' or
		seatcolor.part like '1264SW%' or
		1 = 0) and
	seatcolor.part not like '%-%' and
	seatcolor.part not like '%1BF'
order by
	1, 2

insert	dbo.part_machine	
(	part,
	machine,
	sequence,
	mfg_lot_size,
	process_id,
	parts_per_cycle,
	parts_per_hour,
	cycle_unit,
	cycle_time,
	overlap_type,
	overlap_time,
	labor_code,
	activity,
	setup_time,
	crew_size)
select	part = seatcolor.part,
	machine = pm.machine,
	sequence = pm.sequence,
	mfg_lot_size = pm.mfg_lot_size,
	process_id = pm.process_id,
	parts_per_cycle = pm.parts_per_cycle,
	parts_per_hour = pm.parts_per_hour,
	cycle_unit = pm.cycle_unit,
	cycle_time = pm.cycle_time,
	overlap_type = pm.overlap_type,
	overlap_time = pm.overlap_time,
	labor_code = pm.labor_code,
	activity = pm.activity,
	setup_time = pm.setup_time,
	crew_size = pm.crew_size
from	dbo.part seatcolor
	join dbo.part_machine pm on seatcolor.part != pm.part and
		(	seatcolor.part = left(pm.part, 4) + 'SW' + substring(pm.part, 5, 5) or
			seatcolor.part = left(pm.part, 4) + 'LR' + substring(pm.part, 5, 5) or
			seatcolor.part = left(pm.part, 4) + 'RR' + substring(pm.part, 5, 5) or
			1 = 0)
where	(	seatcolor.part like '1211[LR]R%' or
		seatcolor.part like '1217[LR]R%' or
		seatcolor.part like '1231[LR]R%' or
		seatcolor.part like '1211SW%' or
		seatcolor.part like '1217SW%' or
		seatcolor.part like '1231SW%' or
		seatcolor.part like '1262[LR]R%' or
		seatcolor.part like '1263[LR]R%' or
		seatcolor.part like '1264[LR]R%' or
		seatcolor.part like '1262SW%' or
		seatcolor.part like '1263SW%' or
		seatcolor.part like '1264SW%' or
		1 = 0) and
	seatcolor.part not like '%-%' and
	seatcolor.part not like '%1BF'
order by
	1, 2

insert	dbo.activity_router
(	parent_part,
	sequence,
	code,
	part,
	notes,
	labor,
	material,
	cost_bill,
	group_location,
	process,
	doc1,
	doc2,
	doc3,
	doc4,
	cost,
	price,
	cost_price_factor,
	time_stamp)
select	parent_part = seatcolor.part,
	sequence = pa.sequence,
	code = pa.code,
	part = seatcolor.part,
	notes = pa.notes,
	labor = pa.labor,
	material = pa.material,
	cost_bill = pa.cost_bill,
	group_location = pa.group_location,
	process = pa.process,
	doc1 = pa.doc1,
	doc2 = pa.doc2,
	doc3 = pa.doc3,
	doc4 = pa.doc4,
	cost = pa.cost,
	price = pa.price,
	cost_price_factor = pa.cost_price_factor,
	time_stamp = pa.time_stamp
from	dbo.part seatcolor
	join dbo.activity_router pa on seatcolor.part != pa.part and
		(	seatcolor.part = left(pa.part, 4) + 'SW' + substring(pa.part, 5, 5) or
			seatcolor.part = left(pa.part, 4) + 'LR' + substring(pa.part, 5, 5) or
			seatcolor.part = left(pa.part, 4) + 'RR' + substring(pa.part, 5, 5) or
			1 = 0)
where	(	seatcolor.part like '1211[LR]R%' or
		seatcolor.part like '1217[LR]R%' or
		seatcolor.part like '1231[LR]R%' or
		seatcolor.part like '1211SW%' or
		seatcolor.part like '1217SW%' or
		seatcolor.part like '1231SW%' or
		seatcolor.part like '1262[LR]R%' or
		seatcolor.part like '1263[LR]R%' or
		seatcolor.part like '1264[LR]R%' or
		seatcolor.part like '1262SW%' or
		seatcolor.part like '1263SW%' or
		seatcolor.part like '1264SW%' or
		1 = 0) and
	seatcolor.part not like '%-%' and
	seatcolor.part not like '%1BF'
order by
	1, 2

--Colors of buckets.
insert	dbo.bill_of_material_ec
(	parent_part,
	part,
	start_datetime,
	type,
	quantity,
	unit_measure,
	reference_no,
	std_qty,
	scrap_factor,
	engineering_level,
	operator,
	substitute_part,
	date_changed,
	note)
select	parent_part = seatcolor.part,
	part = BaseMaterialPart.part,
	start_datetime = getdate(),
	type = 'M',
	quantity =
		case	when substring(seatcolor.part, 5, 2) = '19' then 3.5
			when substring(seatcolor.part, 5, 2) = '20' then 3.8
			when substring(seatcolor.part, 5, 2) = '21' then 3.8454
		end * (1 - InjectionMoldingColorFormulas.ColorantUsage),
	unit_measure = 'LB',
	reference_no = null,
	std_qty =
		case	when substring(seatcolor.part, 5, 2) = '19' then 3.5
			when substring(seatcolor.part, 5, 2) = '20' then 3.8
			when substring(seatcolor.part, 5, 2) = '21' then 3.8454
		end * (1 - InjectionMoldingColorFormulas.ColorantUsage),
	scrap_factor = 0,
	engineering_level = null,
	operator = null,
	substitute_part = 'N',
	date_changed = getdate(),
	note = null
from	dbo.part seatcolor
	join dbo.InjectionMoldingColorFormulas InjectionMoldingColorFormulas on InjectionMoldingColorFormulas.FormulationChart = '12S BUCKET' and
		substring(seatcolor.part, 7, 3) = InjectionMoldingColorFormulas.ColorAbbreviation
	left join dbo.part BaseMaterialPart on InjectionMoldingColorFormulas.BaseMaterial = BaseMaterialPart.Part
where	(	seatcolor.part like '1200[12][019]%' or
		1 = 0) and
	seatcolor.part not like '1200[12][019]B'
union all
select	parent_part = seatcolor.part,
	part = ColorantPart.part,
	start_datetime = getdate(),
	type = 'M',
	quantity =
		case	when substring(seatcolor.part, 5, 2) = '19' then 3.5
			when substring(seatcolor.part, 5, 2) = '20' then 3.8
			when substring(seatcolor.part, 5, 2) = '21' then 3.8454
		end * (InjectionMoldingColorFormulas.ColorantUsage),
	unit_measure = 'LB',
	reference_no = null,
	std_qty =
		case	when substring(seatcolor.part, 5, 2) = '19' then 3.5
			when substring(seatcolor.part, 5, 2) = '20' then 3.8
			when substring(seatcolor.part, 5, 2) = '21' then 3.8454
		end * (InjectionMoldingColorFormulas.ColorantUsage),
	scrap_factor = 0,
	engineering_level = null,
	operator = null,
	substitute_part = 'N',
	date_changed = getdate(),
	note = null
from	dbo.part seatcolor
	join dbo.InjectionMoldingColorFormulas InjectionMoldingColorFormulas on InjectionMoldingColorFormulas.FormulationChart = '12S BUCKET' and
		substring(seatcolor.part, 7, 3) = InjectionMoldingColorFormulas.ColorAbbreviation
	left join dbo.part ColorantPart on InjectionMoldingColorFormulas.Colorant = ColorantPart.Part
where	(	seatcolor.part like '1200[12][019]%' or
		1 = 0) and
	seatcolor.part not like '1200[12][019]B'
order by
	1, 2

--Colors of bracket assemblies.
insert	dbo.bill_of_material_ec
(	parent_part,
	part,
	start_datetime,
	type,
	quantity,
	unit_measure,
	reference_no,
	std_qty,
	scrap_factor,
	engineering_level,
	operator,
	substitute_part,
	date_changed,
	note)
select	parent_part = seatcolor.part,
	part =
	case	when bom.part like '1205[LR]-S-%' then left(bom.part, 8) + substring(seatcolor.part, 5, 3)
		else bom.part
	end,
	--bom.parent_part,
	start_datetime = getdate(),
	--description = coalesce(component.name, 'UNDEFINED'),
	bom.type,
	bom.quantity,
	bom.unit_measure,
	bom.reference_no,
	bom.std_qty,
	bom.scrap_factor,
	bom.engineering_level,
	bom.operator,
	bom.substitute_part,
	date_changed = getdate(),
	bom.note
from	dbo.part seatcolor
	join dbo.bill_of_material_ec bom on getdate() between coalesce(bom.start_datetime, getdate()) and coalesce(bom.end_datetime, getdate()) and
		seatcolor.part != bom.parent_part and
		(	seatcolor.part = left(bom.parent_part, 4) + substring(seatcolor.part, 5, 3) or
			1 = 0) and
		bom.parent_part not like '%UV %'
where	(	seatcolor.part like '1201%' or
		seatcolor.part like '1226%' or
		1 = 0) and
	seatcolor.part not like '1201B' and
	seatcolor.part not like '1226B' and
	exists
	(	select	1
		from	dbo.part
		where	part like '1205[LR]-S-' + substring(seatcolor.part, 5, 3))
union all
select	parent_part = seatcolor.part,
	part =
	case	when bom.part like '1205L-S-%' then '1228L-L-' + substring(seatcolor.part, 7, 3)
		when bom.part like '1205R-S-%' then '1228R-L-' + substring(seatcolor.part, 7, 3)
		else bom.part
	end,
	--bom.parent_part,
	start_datetime = getdate(),
	--description = coalesce(component.name, 'UNDEFINED'),
	bom.type,
	bom.quantity,
	bom.unit_measure,
	bom.reference_no,
	bom.std_qty,
	bom.scrap_factor,
	bom.engineering_level,
	bom.operator,
	bom.substitute_part,
	date_changed = getdate(),
	bom.note
from	dbo.part seatcolor
	join dbo.bill_of_material_ec bom on getdate() between coalesce(bom.start_datetime, getdate()) and coalesce(bom.end_datetime, getdate()) and
		seatcolor.part != bom.parent_part and
		(	seatcolor.part = left(bom.parent_part, 4) + 'SW' + substring(seatcolor.part, 7, 3) or
			1 = 0) and
		bom.parent_part not like '%UV %'
where	(	seatcolor.part like '1201SW%' or
		seatcolor.part like '1226SW%' or
		1 = 0) and
	exists
	(	select	1
		from	dbo.part
		where	part like '1228[LR]-L-' + substring(seatcolor.part, 7, 3))
order by
	1, 2

--Colors of brackets.
insert	dbo.bill_of_material_ec
(	parent_part,
	part,
	start_datetime,
	type,
	quantity,
	unit_measure,
	reference_no,
	std_qty,
	scrap_factor,
	engineering_level,
	operator,
	substitute_part,
	date_changed,
	note)select	parent_part = seatcolor.part,
	part = bom.part,
	--bom.parent_part,
	start_datetime = getdate(),
	--description = coalesce(component.name, 'UNDEFINED'),
	bom.type,
	bom.quantity,
	bom.unit_measure,
	bom.reference_no,
	bom.std_qty,
	bom.scrap_factor,
	bom.engineering_level,
	bom.operator,
	bom.substitute_part,
	date_changed = getdate(),
	bom.note
from	dbo.part seatcolor
	join dbo.bill_of_material_ec bom on getdate() between coalesce(bom.start_datetime, getdate()) and coalesce(bom.end_datetime, getdate()) and
		seatcolor.part != bom.parent_part and
		(	seatcolor.part = substring(seatcolor.part, 1, 4) + substring(bom.parent_part, 5, 2) + substring(seatcolor.part, 7, 5) or
			1 = 0) and
	bom.part = '1233-1'
where	(	seatcolor.part like '1205[LR]-S-%' or
		seatcolor.part like '1228[LR]-L-%' or
		1 = 0) and
	seatcolor.part not like '1205%-B'
union all
select	parent_part = seatcolor.part,
	part = BaseMaterialPart.part,
	start_datetime = getdate(),
	type = 'M',
	quantity =
		case	when substring(seatcolor.part, 1, 4) = '1205' then .29
			when substring(seatcolor.part, 1, 4) = '1228' then .33
		end * (1 - InjectionMoldingColorFormulas.ColorantUsage),
	unit_measure = 'LB',
	reference_no = null,
	std_qty =
		case	when substring(seatcolor.part, 1, 4) = '1205' then .29
			when substring(seatcolor.part, 1, 4) = '1228' then .33
		end * (1 - InjectionMoldingColorFormulas.ColorantUsage),
	scrap_factor = 0,
	engineering_level = null,
	operator = null,
	substitute_part = 'N',
	date_changed = getdate(),
	note = null
from	dbo.part seatcolor
	join dbo.InjectionMoldingColorFormulas InjectionMoldingColorFormulas on InjectionMoldingColorFormulas.FormulationChart = '12S NYLON' and
		substring(seatcolor.part, 9, 3) = InjectionMoldingColorFormulas.ColorAbbreviation
	left join dbo.part BaseMaterialPart on InjectionMoldingColorFormulas.BaseMaterial = BaseMaterialPart.Part
where	(	seatcolor.part like '1205[LR]-S-%' or
		seatcolor.part like '1228[LR]-L-%' or
		1 = 0) and
	seatcolor.part not like '1205%-B'
union all
select	parent_part = seatcolor.part,
	part = ColorantPart.part,
	start_datetime = getdate(),
	type = 'M',
	quantity =
		case	when substring(seatcolor.part, 1, 4) = '1205' then .29
			when substring(seatcolor.part, 1, 4) = '1228' then .33
		end * (InjectionMoldingColorFormulas.ColorantUsage),
	unit_measure = 'LB',
	reference_no = null,
	std_qty =
		case	when substring(seatcolor.part, 1, 4) = '1205' then .29
			when substring(seatcolor.part, 1, 4) = '1228' then .33
		end * (InjectionMoldingColorFormulas.ColorantUsage),
	scrap_factor = 0,
	engineering_level = null,
	operator = null,
	substitute_part = 'N',
	date_changed = getdate(),
	note = null
from	dbo.part seatcolor
	join dbo.InjectionMoldingColorFormulas InjectionMoldingColorFormulas on InjectionMoldingColorFormulas.FormulationChart = '12S NYLON' and
		substring(seatcolor.part, 9, 3) = InjectionMoldingColorFormulas.ColorAbbreviation
	left join dbo.part ColorantPart on InjectionMoldingColorFormulas.Colorant = ColorantPart.Part
where	(	seatcolor.part like '1205[LR]-S-%' or
		seatcolor.part like '1228[LR]-L-%' or
		1 = 0) and
	seatcolor.part not like '1205%-B'
order by
	1, 2

select	bom.parent_part, seatcolor.type, seatcolor.name, bom.part, part.name, case when part.part is null then '*' end
from	dbo.bill_of_material bom
	join part seatcolor on bom.parent_part = seatcolor.part
	left join part on bom.part = part.part
where	(	seatcolor.part like '1211[LR]R[12][019]%' or
		seatcolor.part like '1217[LR]R[12][019]%' or
		seatcolor.part like '1231[LR]R[12][019]%' or
		seatcolor.part like '1211SW[12][019]%' or
		seatcolor.part like '1217SW[12][019]%' or
		seatcolor.part like '1231SW[12][019]%' or
		seatcolor.part like '1211[12][019]%' or
		seatcolor.part like '1217[12][019]%' or
		seatcolor.part like '1231[12][019]%' or
		seatcolor.part like '1262[LR]R[12][019]%' or
		seatcolor.part like '1263[LR]R[12][019]%' or
		seatcolor.part like '1264[LR]R[12][019]%' or
		seatcolor.part like '1262SW[12][019]%' or
		seatcolor.part like '1263SW[12][019]%' or
		seatcolor.part like '1264SW[12][019]%' or
		seatcolor.part like '1262[12][019]%' or
		seatcolor.part like '1263[12][019]%' or
		seatcolor.part like '1264[12][019]%' or
		1 = 0) and
	seatcolor.part not like '%-%' and
	seatcolor.part not like '%1BF'
order by
	1, 4

commit

/*
select distinct	(select name from part where parent_part = part), parent_part
from	dbo.bill_of_material
where	parent_part like '12[1-9][0-9][12][901]B%'

--Indoor v. Outdoor 3/4 cam
select	bom.parent_part, seatcolor.type, seatcolor.name, bom.part, part.name, case when part.part is null then '*' end
from	dbo.bill_of_material bom
	join part seatcolor on bom.parent_part = seatcolor.part
	left join part on bom.part = part.part
where	(	seatcolor.part like '121721%' or
		seatcolor.part like '122021%') and
	seatcolor.part not like '%-%' and
	seatcolor.part not like '%1BF'
order by
	1, 2

--Indoor v. Outdoor 3/4 cam
select	bom.parent_part, seatcolor.type, seatcolor.name, bom.part, part.name, case when part.part is null then '*' end
from	dbo.bill_of_material bom
	join part seatcolor on bom.parent_part = seatcolor.part
	left join part on bom.part = part.part
where	(	seatcolor.part like '1235%' or
		seatcolor.part like '1227%') and
	seatcolor.part not like '%-%' and
	seatcolor.part not like '%1BF'
order by
	1, 2

--buckets:
select	*
from	part
where	part like '120021%'

--Outdoor full fold
select	*
from	part
where	part like '125421%'

--Outdoor 3/4 fold
select	*
from	part
where	part like '122021%'

select	*
from	part seatcolor
where	seatcolor.part like '1211[LR]R%' or
	seatcolor.part like '1217[LR]R%' or
	seatcolor.part like '1231[LR]R%' or
	seatcolor.part like '1211SW%' or
	seatcolor.part like '1217SW%' or
	seatcolor.part like '1231SW%'

*/

