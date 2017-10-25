declare
	@partList varchar(8000)

set
	@partList =
		(	select
				Fx.ToList(p.part)
			from
				dbo.part p
			where
				p.part like '2263%BLK'
		)

select
	BOM = space(xr.BOMLevel * 3) + xr.ChildPart
,	PartList = Fx.ToList(distinct xr.TopPart)
,	Sequence =
		(	select
				max(xr2.Sequence)
			from
				FT.XRt xr2
			where
				xr2.TopPart in
					(	select
							fsstr.value
						from
							dbo.fn_SplitStringToRows(@partList, ', ') fsstr
					)
				and xr2.ChildPart = xr.ChildPart
		)
from
	FT.XRt xr
where
	xr.TopPart in
		(	select
				fsstr.value
			from
				dbo.fn_SplitStringToRows(@partList, ', ') fsstr
		)
group by
	xr.ChildPart
,	xr.BOMLevel
order by
	3