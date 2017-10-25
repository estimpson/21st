
select
	*
from
	dbo.bill_of_material_ec bome
where
	bome.parent_part in
		(	'120019CHL', '120020CRM', '120020DPV', '120021CHL', '120021CRM', '120021DPV', '120021MYR'
		,	'120020CDT', '120021CDT')
	and bome.end_datetime is null
go

begin transaction
go

alter table dbo.bill_of_material_ec disable trigger all
go
declare
	@nowDT datetime
set	@nowDT = getdate()

update
	bome
set end_datetime = @nowDT
from
	dbo.bill_of_material_ec bome
where
	bome.parent_part in
		(	select
				'120019' + mcl.ColorCode
			from
				custom.MoldingColorLetdown mcl
			where
				mcl.MoldApplication = '22-Bucket'
			union all
			select
				'120020' + mcl.ColorCode
			from
				custom.MoldingColorLetdown mcl
			where
				mcl.MoldApplication = '22-Bucket'
			union all
			select
				'120021' + mcl.ColorCode
			from
				custom.MoldingColorLetdown mcl
			where
				mcl.MoldApplication = '22-Bucket'
		)
	and bome.end_datetime is null

insert
	dbo.bill_of_material_ec
(	date_changed
,	parent_part
,	part
,	start_datetime
,	type
,	quantity
,	unit_measure
,	std_qty
,	scrap_factor
,	substitute_part
)
select
	date_changed = @nowDT
,	parent_part = bp.BasePart + mcl.ColorCode
,	part = mcl.ColorantCode
,	start_datetime = @nowDT
,	type = 'M'
,	quantity = bp.Weight * mcl.LetDownRate
,	unit_measure = coalesce(pInv.standard_unit, 'LB')
,	std_qty = bp.Weight * mcl.LetDownRate
,	scrap_factor = 0.04
,	substitute_part = 'N'
from
	custom.MoldingColorLetdown mcl
	left join dbo.part_inventory pInv
		on pInv.part = mcl.ColorantCode
	cross join
		(	select
				BasePart = left(xr.TopPart, 6)
			,	Weight = sum(xr.XQty)
			from
				FT.XRt xr
			where
				xr.TopPart like '1200[12][0-9]BLK'
				and xr.Sequence > 0
			group by
				xr.TopPart
		) bp
where
	mcl.MoldApplication = '22-Bucket'
	and mcl.ColorCode != 'BLK'
	and mcl.ColorantCode != 'N/A'
	and bp.BasePart + mcl.ColorCode in
		(	select
				'120019' + mcl.ColorCode
			from
				custom.MoldingColorLetdown mcl
			where
				mcl.MoldApplication = '22-Bucket'
			union all
			select
				'120020' + mcl.ColorCode
			from
				custom.MoldingColorLetdown mcl
			where
				mcl.MoldApplication = '22-Bucket'
			union all
			select
				'120021' + mcl.ColorCode
			from
				custom.MoldingColorLetdown mcl
			where
				mcl.MoldApplication = '22-Bucket'
		)
union all
select
	date_changed = @nowDT
,	parent_part = bp.BasePart + mcl.ColorCode
,	part = mcl.BaseMaterialCode
,	start_datetime = @nowDT
,	type = 'M'
,	quantity = bp.Weight * (1 - mcl.LetDownRate)
,	unit_measure = pInv.standard_unit
,	std_qty = bp.Weight * (1 - mcl.LetDownRate)
,	scrap_factor = 0.04
,	substitute_part = 'N'
from
	custom.MoldingColorLetdown mcl
	join dbo.part_inventory pInv
		on pInv.part = mcl.BaseMaterialCode
	cross join
		(	select
				BasePart = left(xr.TopPart, 6)
			,	Weight = sum(xr.XQty)
			from
				FT.XRt xr
			where
				xr.TopPart like '1200[12][0-9]BLK'
				and xr.Sequence > 0
			group by
				xr.TopPart
		) bp
where
	mcl.MoldApplication = '22-Bucket'
	and mcl.ColorCode != 'BLK'
	and mcl.ColorantCode != 'N/A'
	and bp.BasePart + mcl.ColorCode in
		(	select
				'120019' + mcl.ColorCode
			from
				custom.MoldingColorLetdown mcl
			where
				mcl.MoldApplication = '22-Bucket'
			union all
			select
				'120020' + mcl.ColorCode
			from
				custom.MoldingColorLetdown mcl
			where
				mcl.MoldApplication = '22-Bucket'
			union all
			select
				'120021' + mcl.ColorCode
			from
				custom.MoldingColorLetdown mcl
			where
				mcl.MoldApplication = '22-Bucket'
		)
order by
	1
,	2

alter table dbo.bill_of_material_ec enable trigger all
go

select
	*
from
	dbo.bill_of_material bom
where
	bom.parent_part in
		(	select
				'120019' + mcl.ColorCode
			from
				custom.MoldingColorLetdown mcl
			where
				mcl.MoldApplication = '22-Bucket'
			union all
			select
				'120020' + mcl.ColorCode
			from
				custom.MoldingColorLetdown mcl
			where
				mcl.MoldApplication = '22-Bucket'
			union all
			select
				'120021' + mcl.ColorCode
			from
				custom.MoldingColorLetdown mcl
			where
				mcl.MoldApplication = '22-Bucket'
		)
go

--rollback
commit
go
