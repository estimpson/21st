/*
alter table dbo.part disable trigger all

insert
	dbo.part
(	part
,	name
,	cross_ref
,	class
,	type
,	commodity
,	group_technology
,	quality_alert
,	description_short
,	description_long
,	serial_type
,	product_line
,	configuration
,	standard_cost
,	user_defined_1
,	user_defined_2
,	flag
,	engineering_level
,	drawing_number
,	gl_account_code
,	eng_effective_date
,	low_level_code
)
select
	pNew.part
,	pNew.name
,	pNew.cross_ref
,	pNew.class
,	pNew.type
,	pNew.commodity
,	pNew.group_technology
,	pNew.quality_alert
,	pNew.description_short
,	pNew.description_long
,	pNew.serial_type
,	pNew.product_line
,	pNew.configuration
,	pNew.standard_cost
,	pNew.user_defined_1
,	pNew.user_defined_2
,	pNew.flag
,	pNew.engineering_level
,	pNew.drawing_number
,	pNew.gl_account_code
,	pNew.eng_effective_date
,	pNew.low_level_code
--into
--	FT.New22_Seats_part
from
	(	select
			old_part = p.part
		,	part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
		,	name = replace(p.name, 'BLACK', upper(mcl.ColorName))
		,	p.cross_ref
		,	p.class
		,	p.type
		,	p.commodity
		,	p.group_technology
		,	p.quality_alert
		,	p.description_short
		,	p.description_long
		,	p.serial_type
		,	p.product_line
		,	p.configuration
		,	p.standard_cost
		,	user_defined_1 = upper(p.user_defined_1)
		,	p.user_defined_2
		,	p.flag
		,	p.engineering_level
		,	p.drawing_number
		,	p.gl_account_code
		,	p.eng_effective_date
		,	p.low_level_code
		from
			dbo.part p
			join custom.MoldingColorLetdown mcl
				on mcl.MoldApplication = '22-Bucket'
		where
			p.part like '12[136]%[12][901]B'
	) pNew
where
	not exists
		(	select
				*
			from
				dbo.part p2
			where
				p2.part = pNew.part
		)
order by
	pNew.part

alter table dbo.part enable trigger all

alter table dbo.part_inventory disable trigger all

--insert
--	dbo.part_inventory
--(	part
--,	standard_pack
--,	unit_weight
--,	standard_unit
--,	cycle
--,	abc
--,	saftey_stock_qty
--,	primary_location
--,	location_group
--,	ipa
--,	label_format
--,	shelf_life_days
--,	material_issue_type
--,	safety_part
--,	upc_code
--,	dim_code
--,	configurable
--,	next_suffix
--,	drop_ship_part
--)
select
	pInvNew.part
,	pInvNew.standard_pack
,	pInvNew.unit_weight
,	pInvNew.standard_unit
,	pInvNew.cycle
,	pInvNew.abc
,	pInvNew.saftey_stock_qty
,	pInvNew.primary_location
,	pInvNew.location_group
,	pInvNew.ipa
,	pInvNew.label_format
,	pInvNew.shelf_life_days
,	pInvNew.material_issue_type
,	pInvNew.safety_part
,	pInvNew.upc_code
,	pInvNew.dim_code
,	pInvNew.configurable
,	pInvNew.next_suffix
,	pInvNew.drop_ship_part
into
	FT.New22_Seats_part_inventory
from
	(	select
			old_part = p.part
		,	part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
		,	pInv.standard_pack
		,	pInv.unit_weight
		,	pInv.standard_unit
		,	pInv.cycle
		,	pInv.abc
		,	pInv.saftey_stock_qty
		,	pInv.primary_location
		,	pInv.location_group
		,	pInv.ipa
		,	pInv.label_format
		,	pInv.shelf_life_days
		,	pInv.material_issue_type
		,	pInv.safety_part
		,	pInv.upc_code
		,	pInv.dim_code
		,	pInv.configurable
		,	pInv.next_suffix
		,	pInv.drop_ship_part
		from
			dbo.part p
			join custom.MoldingColorLetdown mcl
				on mcl.MoldApplication = '22-Bucket'
			join dbo.part_inventory pInv
				on pInv.part = p.part
		where
			p.part like '12[136]%[12][901]B'
	) pInvNew
where
	not exists
		(	select
				*
			from
				dbo.part_inventory pInv2
			where
				pInv2.part = pInvNew.part
		)
order by
	pInvNew.part

alter table dbo.part_inventory enable trigger all

alter table dbo.part_standard disable trigger all

insert
	dbo.part_standard
(	part
,	price
,	cost
,	account_number
,	material
,	labor
,	burden
,	other
,	cost_cum
,	material_cum
,	burden_cum
,	other_cum
,	labor_cum
,	flag
,	premium
,	qtd_cost
,	qtd_material
,	qtd_labor
,	qtd_burden
,	qtd_other
,	qtd_cost_cum
,	qtd_material_cum
,	qtd_labor_cum
,	qtd_burden_cum
,	qtd_other_cum
,	planned_cost
,	planned_material
,	planned_labor
,	planned_burden
,	planned_other
,	planned_cost_cum
,	planned_material_cum
,	planned_labor_cum
,	planned_burden_cum
,	planned_other_cum
,	frozen_cost
,	frozen_material
,	frozen_burden
,	frozen_labor
,	frozen_other
,	frozen_cost_cum
,	frozen_material_cum
,	frozen_burden_cum
,	frozen_labor_cum
,	frozen_other_cum
,	cost_changed_date
,	qtd_changed_date
,	planned_changed_date
,	frozen_changed_date
,	os_cost
,	os_cost_cum
,	os_qtd_cost
,	os_qtd_cost_cum
,	os_planned_cost
,	os_planned_cost_cum
,	os_frozen_cost
,	os_frozen_cost_cum
)
select
	psNew.part
,	psNew.price
,	psNew.cost
,	psNew.account_number
,	psNew.material
,	psNew.labor
,	psNew.burden
,	psNew.other
,	psNew.cost_cum
,	psNew.material_cum
,	psNew.burden_cum
,	psNew.other_cum
,	psNew.labor_cum
,	psNew.flag
,	psNew.premium
,	psNew.qtd_cost
,	psNew.qtd_material
,	psNew.qtd_labor
,	psNew.qtd_burden
,	psNew.qtd_other
,	psNew.qtd_cost_cum
,	psNew.qtd_material_cum
,	psNew.qtd_labor_cum
,	psNew.qtd_burden_cum
,	psNew.qtd_other_cum
,	psNew.planned_cost
,	psNew.planned_material
,	psNew.planned_labor
,	psNew.planned_burden
,	psNew.planned_other
,	psNew.planned_cost_cum
,	psNew.planned_material_cum
,	psNew.planned_labor_cum
,	psNew.planned_burden_cum
,	psNew.planned_other_cum
,	psNew.frozen_cost
,	psNew.frozen_material
,	psNew.frozen_burden
,	psNew.frozen_labor
,	psNew.frozen_other
,	psNew.frozen_cost_cum
,	psNew.frozen_material_cum
,	psNew.frozen_burden_cum
,	psNew.frozen_labor_cum
,	psNew.frozen_other_cum
,	psNew.cost_changed_date
,	psNew.qtd_changed_date
,	psNew.planned_changed_date
,	psNew.frozen_changed_date
,	psNew.os_cost
,	psNew.os_cost_cum
,	psNew.os_qtd_cost
,	psNew.os_qtd_cost_cum
,	psNew.os_planned_cost
,	psNew.os_planned_cost_cum
,	psNew.os_frozen_cost
,	psNew.os_frozen_cost_cum
--into
--	FT.New22_Seat_part_standard
from
	(	select
			old_part = p.part
		,	part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
		,	ps.price
		,	ps.cost
		,	ps.account_number
		,	ps.material
		,	ps.labor
		,	ps.burden
		,	ps.other
		,	ps.cost_cum
		,	ps.material_cum
		,	ps.burden_cum
		,	ps.other_cum
		,	ps.labor_cum
		,	ps.flag
		,	ps.premium
		,	ps.qtd_cost
		,	ps.qtd_material
		,	ps.qtd_labor
		,	ps.qtd_burden
		,	ps.qtd_other
		,	ps.qtd_cost_cum
		,	ps.qtd_material_cum
		,	ps.qtd_labor_cum
		,	ps.qtd_burden_cum
		,	ps.qtd_other_cum
		,	ps.planned_cost
		,	ps.planned_material
		,	ps.planned_labor
		,	ps.planned_burden
		,	ps.planned_other
		,	ps.planned_cost_cum
		,	ps.planned_material_cum
		,	ps.planned_labor_cum
		,	ps.planned_burden_cum
		,	ps.planned_other_cum
		,	ps.frozen_cost
		,	ps.frozen_material
		,	ps.frozen_burden
		,	ps.frozen_labor
		,	ps.frozen_other
		,	ps.frozen_cost_cum
		,	ps.frozen_material_cum
		,	ps.frozen_burden_cum
		,	ps.frozen_labor_cum
		,	ps.frozen_other_cum
		,	ps.cost_changed_date
		,	ps.qtd_changed_date
		,	ps.planned_changed_date
		,	ps.frozen_changed_date
		,	ps.os_cost
		,	ps.os_cost_cum
		,	ps.os_qtd_cost
		,	ps.os_qtd_cost_cum
		,	ps.os_planned_cost
		,	ps.os_planned_cost_cum
		,	ps.os_frozen_cost
		,	ps.os_frozen_cost_cum
		from
			dbo.part p
			join custom.MoldingColorLetdown mcl
				on mcl.MoldApplication = '22-Bucket'
			join dbo.part_standard ps
				on ps.part = p.part
		where
			p.part like '12[136]%[12][901]B'
	) psNew
where
	not exists
		(	select
				*
			from
				dbo.part_standard ps2
			where
				ps2.part = psNew.part
		)
order by
	psNew.part

alter table dbo.part_standard enable trigger all

insert
	dbo.part_characteristics
(	part
,	unit_weight
,	length_x
,	height_y
,	width_z
,	color
,	hazardous
,	part_size
,	user_defined_1
,	package_type
,	returnable
)
select
	pcNew.part
,	pcNew.unit_weight
,	pcNew.length_x
,	pcNew.height_y
,	pcNew.width_z
,	pcNew.color
,	pcNew.hazardous
,	pcNew.part_size
,	pcNew.user_defined_1
,	pcNew.package_type
,	pcNew.returnable
from
	(	select
			old_part = p.part
		,	part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
		,	pc.unit_weight
		,	pc.length_x
		,	pc.height_y
		,	pc.width_z
		,	pc.color
		,	pc.hazardous
		,	pc.part_size
		,	pc.user_defined_1
		,	pc.package_type
		,	pc.returnable
		from
			dbo.part p
			join custom.MoldingColorLetdown mcl
				on mcl.MoldApplication = '22-Bucket'
			join dbo.part_characteristics pc
				on pc.part = p.part
		where
			p.part like '12[136]%[12][901]B'
	) pcNew
where
	not exists
		(	select
				*
			from
				dbo.part_characteristics pc2
			where
				pc2.part = pcNew.part
		)
order by
	pcNew.part

alter table dbo.part_packaging disable trigger all

insert
	dbo.part_packaging
(	part
,	code
,	quantity
,	manual_tare
,	label_format
,	round_to_whole_number
,	package_is_object
,	inactivity_time
,	threshold_upper
,	threshold_lower
,	unit
,	stage_using_weight
,	inactivity_amount
,	threshold_upper_type
,	threshold_lower_type
,	serial_type
)
select
	ppNew.part
,	ppNew.code
,	ppNew.quantity
,	ppNew.manual_tare
,	ppNew.label_format
,	ppNew.round_to_whole_number
,	ppNew.package_is_object
,	ppNew.inactivity_time
,	ppNew.threshold_upper
,	ppNew.threshold_lower
,	ppNew.unit
,	ppNew.stage_using_weight
,	ppNew.inactivity_amount
,	ppNew.threshold_upper_type
,	ppNew.threshold_lower_type
,	ppNew.serial_type
--into
--	FT.New22_Seats_part_packaging
from
	(	select
			old_part = p.part
		,	part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
		,	pp.code
		,	pp.quantity
		,	pp.manual_tare
		,	pp.label_format
		,	pp.round_to_whole_number
		,	pp.package_is_object
		,	pp.inactivity_time
		,	pp.threshold_upper
		,	pp.threshold_lower
		,	pp.unit
		,	pp.stage_using_weight
		,	pp.inactivity_amount
		,	pp.threshold_upper_type
		,	pp.threshold_lower_type
		,	pp.serial_type
		from
			dbo.part p
			join custom.MoldingColorLetdown mcl
				on mcl.MoldApplication = '22-Bucket'
			join dbo.part_packaging pp
				on pp.part = p.part
		where
			p.part like '12[136]%[12][901]B'
	) ppNew
where
	not exists
		(	select
				*
			from
				dbo.part_packaging pp2
			where
				pp2.part = ppNew.part
				and pp2.code = ppNew.code
		)
order by
	ppNew.part

alter table dbo.part_packaging enable trigger all

alter table dbo.part_customer disable trigger all

insert
	dbo.part_customer
(	part
,	customer
,	customer_part
,	customer_standard_pack
,	taxable
,	customer_unit
,	type
,	upc_code
,	blanket_price
)
select
	pcNew.part
,	pcNew.customer
,	pcNew.customer_part
,	pcNew.customer_standard_pack
,	pcNew.taxable
,	pcNew.customer_unit
,	pcNew.type
,	pcNew.upc_code
,	pcNew.blanket_price
--into
--	FT.New22_Seats_part_customer
from
	(	select
			old_part = p.part
		,	part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
		,	pc.customer
		,	pc.customer_part
		,	pc.customer_standard_pack
		,	pc.taxable
		,	pc.customer_unit
		,	pc.type
		,	pc.upc_code
		,	pc.blanket_price
		from
			dbo.part p
			join custom.MoldingColorLetdown mcl
				on mcl.MoldApplication = '22-Bucket'
			join dbo.part_customer pc
				on pc.part = p.part
		where
			p.part like '12[136]%[12][901]B'
	) pcNew
where
	not exists
		(	select
				*
			from
				dbo.part_customer pc2
			where
				pc2.part = pcNew.part
				and pc2.customer = pcNew.customer
		)
order by
	pcNew.part

alter table dbo.part_customer enable trigger all

alter table dbo.part_machine disable trigger all

insert
	dbo.part_machine
(	part
,	machine
,	sequence
,	mfg_lot_size
,	process_id
,	parts_per_cycle
,	parts_per_hour
,	cycle_unit
,	cycle_time
,	overlap_type
,	overlap_time
,	labor_code
,	activity
,	setup_time
,	crew_size
)
select
	pmNew.part
,   pmNew.machine
,   pmNew.sequence
,   pmNew.mfg_lot_size
,   pmNew.process_id
,   pmNew.parts_per_cycle
,   pmNew.parts_per_hour
,   pmNew.cycle_unit
,   pmNew.cycle_time
,   pmNew.overlap_type
,   pmNew.overlap_time
,   pmNew.labor_code
,   pmNew.activity
,   pmNew.setup_time
,   pmNew.crew_size
--into
--	FT.New22_Seats_part_machine
from
	(	select
			old_part = p.part
		,	part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
		,	pm.machine
		,	pm.sequence
		,	pm.mfg_lot_size
		,	pm.process_id
		,	pm.parts_per_cycle
		,	pm.parts_per_hour
		,	pm.cycle_unit
		,	pm.cycle_time
		,	pm.overlap_type
		,	pm.overlap_time
		,	pm.labor_code
		,	pm.activity
		,	pm.setup_time
		,	pm.crew_size
		from
			dbo.part p
			join custom.MoldingColorLetdown mcl
				on mcl.MoldApplication = '22-Bucket'
			join dbo.part_machine pm
				on pm.part = p.part
		where
			p.part like '12[136]%[12][901]B'
	) pmNew
where
	not exists
		(	select
				*
			from
				dbo.part_machine pm2
			where
				pm2.part = pmNew.part
				and
				(	pm2.machine = pmNew.machine
					or pm2.sequence = pmNew.sequence
				)
		)
order by
	pmNew.part

alter table dbo.part_machine enable trigger all

alter table dbo.activity_router disable trigger all

insert
	dbo.activity_router
(	parent_part
,	sequence
,	code
,	part
,	notes
,	labor
,	material
,	cost_bill
,	group_location
,	process
,	doc1
,	doc2
,	doc3
,	doc4
,	cost
,	price
,	cost_price_factor
,	time_stamp
)
select
	arNew.parent_part
,   arNew.sequence
,   arNew.code
,   arNew.part
,   arNew.notes
,   arNew.labor
,   arNew.material
,   arNew.cost_bill
,   arNew.group_location
,   arNew.process
,   arNew.doc1
,   arNew.doc2
,   arNew.doc3
,   arNew.doc4
,   arNew.cost
,   arNew.price
,   arNew.cost_price_factor
,   arNew.time_stamp
--into
--	FT.New22_Seats_activity_router
from
	(	select
			old_part = p.part
		,	parent_part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
		,	ar.sequence
		,   ar.code
		,   part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
		,	ar.notes
		,   ar.labor
		,   ar.material
		,   ar.cost_bill
		,   ar.group_location
		,   ar.process
		,   ar.doc1
		,   ar.doc2
		,   ar.doc3
		,   ar.doc4
		,   ar.cost
		,   ar.price
		,   ar.cost_price_factor
		,   ar.time_stamp
		from
			dbo.part p
			join custom.MoldingColorLetdown mcl
				on mcl.MoldApplication = '22-Bucket'
			join dbo.activity_router ar
				on ar.parent_part = p.part
				and ar.part = p.part
		where
			p.part like '12[136]%[12][901]B'
	) arNew
where
	not exists
		(	select
				*
			from
				dbo.activity_router ar2
			where
				ar2.part = arNew.part
				and ar2.parent_part = arNew.parent_part
		)
order by
	arNew.part

alter table dbo.activity_router enable trigger all

alter table dbo.bill_of_material_ec disable trigger all

insert
	dbo.bill_of_material_ec
(	parent_part
,	part
,	start_datetime
,	type
,	quantity
,	unit_measure
,	reference_no
,	std_qty
,	scrap_factor
,	engineering_level
,	operator
,	substitute_part
,	date_changed
,	note
)
select
	newBOM.parent_part
,	newBOM.part
,	newBOM.start_datetime
,	newBOM.type
,	newBOM.quantity
,	newBOM.unit_measure
,	newBOM.reference_no
,	newBOM.std_qty
,	newBOM.scrap_factor
,	newBOM.engineering_level
,	newBOM.operator
,	newBOM.substitute_part
,	newBOM.date_changed
,	newBOM.note
--into
--	FT.New22_Seat_bill_of_material_ec
from
	(	select
			bomNew.parent_part
		,   bomNew.part
		,	start_datetime = getdate()
		,   bomNew.type
		,   bomNew.quantity
		,   bomNew.unit_measure
		,   bomNew.reference_no
		,   bomNew.std_qty
		,   bomNew.scrap_factor
		,   bomNew.engineering_level
		,   bomNew.operator
		,   bomNew.substitute_part
		,   bomNew.date_changed
		,   bomNew.note
		from
			(	select
					old_part = p.part
				,	parent_part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
				,	part = substring(bom1.part, 1, len(bom1.part) - 1) + mcl.ColorCode
				,   bom1.type
				,   bom1.quantity
				,   bom1.unit_measure
				,   bom1.reference_no
				,   bom1.std_qty
				,   bom1.scrap_factor
				,   bom1.engineering_level
				,   bom1.operator
				,   bom1.substitute_part
				,   bom1.date_changed
				,   bom1.note
				from
					dbo.part p
					join custom.MoldingColorLetdown mcl
						on mcl.MoldApplication = '22-Bucket'
					join dbo.bill_of_material_ec bom1
						on bom1.parent_part = p.part
						and bom1.part like '1200%[12][901]B'
						and bom1.end_datetime is null
				where
					p.part like '12[136]%[12][901]B'
			) bomNew
		where
			not exists
				(	select
						*
					from
						dbo.bill_of_material bom2
					where
						bom2.part = bomNew.part
						and bom2.parent_part = bomNew.parent_part
				)
		union all
		select
			bomNew.parent_part
		,   bomNew.part
		,	start_datetime = getdate()
		,   bomNew.type
		,   bomNew.quantity
		,   bomNew.unit_measure
		,   bomNew.reference_no
		,   bomNew.std_qty
		,   bomNew.scrap_factor
		,   bomNew.engineering_level
		,   bomNew.operator
		,   bomNew.substitute_part
		,   bomNew.date_changed
		,   bomNew.note
		from
			(	select
					old_part = p.part
				,	parent_part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
				,	part = bom1.part
				,   bom1.type
				,   bom1.quantity
				,   bom1.unit_measure
				,   bom1.reference_no
				,   bom1.std_qty
				,   bom1.scrap_factor
				,   bom1.engineering_level
				,   bom1.operator
				,   bom1.substitute_part
				,   bom1.date_changed
				,   bom1.note
				from
					dbo.part p
					join custom.MoldingColorLetdown mcl
						on mcl.MoldApplication = '22-Bucket'
					join dbo.bill_of_material_ec bom1
						on bom1.parent_part = p.part
						and bom1.part in ('1222', '1252', '1232', '1227', '1235', 'C43978-025-A', 'C43978-025-963')
						and bom1.end_datetime is null
				where
					p.part like '12[136]%[12][901]B'
			) bomNew
		where
			not exists
				(	select
						*
					from
						dbo.bill_of_material bom2
					where
						bom2.part = bomNew.part
						and bom2.parent_part = bomNew.parent_part
				)
		union all
		select
			bomNew.parent_part
		,   bomNew.part
		,	start_datetime = getdate()
		,   bomNew.type
		,   bomNew.quantity
		,   bomNew.unit_measure
		,   bomNew.reference_no
		,   bomNew.std_qty
		,   bomNew.scrap_factor
		,   bomNew.engineering_level
		,   bomNew.operator
		,   bomNew.substitute_part
		,   bomNew.date_changed
		,   bomNew.note
		from
			(	select
					old_part = p.part
				,	parent_part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
				,	part = case when bom1.part like '12[02][16]SW%' then '1266' else '1265' end + mcl.ColorCode
				,   type = max(bom1.type)
				,   quantity = sum(bom1.quantity)
				,   unit_measure = max(bom1.unit_measure)
				,   reference_no = max(bom1.reference_no)
				,   std_qty = sum(bom1.std_qty)
				,   scrap_factor = min(bom1.scrap_factor)
				,   engineering_level = max(bom1.engineering_level)
				,   operator = max(bom1.operator)
				,   substitute_part = min(bom1.substitute_part)
				,   date_changed = min(bom1.date_changed)
				,   note = min(bom1.note)
				from
					dbo.part p
					join custom.MoldingColorLetdown mcl
						on mcl.MoldApplication = '22-Bucket'
					join dbo.bill_of_material_ec bom1
						on bom1.parent_part = p.part
						and
						(	bom1.part like '1201%'
							or bom1.part like '1226%'
						)
						and bom1.end_datetime is null
				where
					p.part like '12[136]%[12][901]B'
				group by
					p.part
				,	'2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
				,	case when bom1.part like '12[02][16]SW%' then '1266' else '1265' end + mcl.ColorCode
			) bomNew
		where
			not exists
				(	select
						*
					from
						dbo.bill_of_material bom2
					where
						bom2.part = bomNew.part
						and bom2.parent_part = bomNew.parent_part
				)
		union all
		select
			bomNew.parent_part
		,   bomNew.part
		,	start_datetime = getdate()
		,   bomNew.type
		,   bomNew.quantity
		,   bomNew.unit_measure
		,   bomNew.reference_no
		,   bomNew.std_qty
		,   bomNew.scrap_factor
		,   bomNew.engineering_level
		,   bomNew.operator
		,   bomNew.substitute_part
		,   bomNew.date_changed
		,   bomNew.note
		from
			(	select
					old_part = p.part
				,	parent_part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
				,	part = case when bom1.part like '12[02][16]SW%' then '1268' else '1267' end
				,   type = max(bom1.type)
				,   quantity = sum(bom1.quantity)
				,   unit_measure = max(bom1.unit_measure)
				,   reference_no = max(bom1.reference_no)
				,   std_qty = sum(bom1.std_qty)
				,   scrap_factor = min(bom1.scrap_factor)
				,   engineering_level = max(bom1.engineering_level)
				,   operator = max(bom1.operator)
				,   substitute_part = min(bom1.substitute_part)
				,   date_changed = min(bom1.date_changed)
				,   note = min(bom1.note)
				from
					dbo.part p
					join custom.MoldingColorLetdown mcl
						on mcl.MoldApplication = '22-Bucket'
					join dbo.bill_of_material_ec bom1
						on bom1.parent_part = p.part
						and
						(	bom1.part like '1201%'
							or bom1.part like '1226%'
						)
						and bom1.end_datetime is null
				where
					p.part like '12[136]%[12][901]B'
				group by
					p.part
				,	'2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
				,	case when bom1.part like '12[02][16]SW%' then '1268' else '1267' end
			) bomNew
		where
			not exists
				(	select
						*
					from
						dbo.bill_of_material bom2
					where
						bom2.part = bomNew.part
						and bom2.parent_part = bomNew.parent_part
				)
		union all
		select
			bomNew.parent_part
		,   bomNew.part
		,	start_datetime = getdate()
		,   bomNew.type
		,   bomNew.quantity
		,   bomNew.unit_measure
		,   bomNew.reference_no
		,   bomNew.std_qty
		,   bomNew.scrap_factor
		,   bomNew.engineering_level
		,   bomNew.operator
		,   bomNew.substitute_part
		,   bomNew.date_changed
		,   bomNew.note
		from
			(	select
					old_part = p.part
				,	parent_part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
				,	part = '1271'
				,   type = 'M'
				,   quantity = 1
				,   unit_measure = 'EA'
				,   reference_no = null
				,   std_qty = 1
				,   scrap_factor = 0
				,   engineering_level = null
				,   operator = null
				,   substitute_part = 'N'
				,   date_changed = getdate()
				,   note = null
				from
					dbo.part p
					join custom.MoldingColorLetdown mcl
						on mcl.MoldApplication = '22-Bucket'
				where
					p.part like '12[136]%[12][901]B'
			) bomNew
		where
			not exists
				(	select
						*
					from
						dbo.bill_of_material bom2
					where
						bom2.part = bomNew.part
						and bom2.parent_part = bomNew.parent_part
				)
		union all
		select
			bomNew.parent_part
		,   bomNew.part
		,	start_datetime = getdate()
		,   bomNew.type
		,   bomNew.quantity
		,   bomNew.unit_measure
		,   bomNew.reference_no
		,   bomNew.std_qty
		,   bomNew.scrap_factor
		,   bomNew.engineering_level
		,   bomNew.operator
		,   bomNew.substitute_part
		,   bomNew.date_changed
		,   bomNew.note
		from
			(	select
					old_part = p.part
				,	parent_part = '2' + substring(p.part, 2, len(p.part) - 2) + mcl.ColorCode
				,	part = '1236'
				,   type = 'M'
				,   quantity = 1
				,   unit_measure = 'EA'
				,   reference_no = null
				,   std_qty = 1
				,   scrap_factor = 0
				,   engineering_level = null
				,   operator = null
				,   substitute_part = 'N'
				,   date_changed = getdate()
				,   note = null
				from
					dbo.part p
					join custom.MoldingColorLetdown mcl
						on mcl.MoldApplication = '22-Bucket'
				where
					p.part like '12[136]%[12][901]B'
			) bomNew
		where
			not exists
				(	select
						*
					from
						dbo.bill_of_material bom2
					where
						bom2.part = bomNew.part
						and bom2.parent_part = bomNew.parent_part
				)
		) newBOM
order by
	1
,	2

alter table dbo.bill_of_material_ec enable trigger all
*/

select
	*
from
	(	select
			bom.parent_part
		,   bom.part
		,   bom.std_qty
		,   bom.scrap_factor
		,	newPart =
				case
					when bom.part like '1201SW%' then '126[68]%'
					when bom.part like '1226SW%' then '126[68]%'
					when bom.part like '1201%' then '126[57]%'
					when bom.part like '1226%' then '126[57]%'
					when bom.part = '1223' then '1271'
					when bom.part = '1204' then '1236'
					when bom.part = '1222QR' then 'TBD'
					else bom.part
				end
		from
			dbo.bill_of_material bom
		where
			parent_part = '121721B'
	) oldBom
	full join
	(	select
			bom.parent_part
		,   bom.part
		,   bom.std_qty
		,   bom.scrap_factor
		from
			FIS_Empower_21st.dbo.bill_of_material bom
		where
			parent_part = '221721BLK'
	) newBOM
	on newBOM.part like oldBom.newPart

select
	*
from
	dbo.bill_of_material bom
where
	bom.parent_part = '221721CHL'
