create view dbo.Scheduling_InLineProcessNew
as
with 
	xr
	(	TopMachineCode, MachineCode, BOMStructure, XRtID, TopPartCode, ChildPartCode, BOMID, Sequence, BOMLevel, XQty, XScrap, Hierarchy
	)
as
	(	select
				TopMachineCode = pmTopPrimary.machine
			,	MachineCode = pm.machine
			,	BOMStructure = space(xr.BOMLevel * 3) + xr.ChildPart
			,	XRtID = xr.ID
			,   TopPartCode = xr.TopPart
			,   ChildPartCode = xr.ChildPart
			,   xr.BOMID
			,   xr.Sequence
			,   xr.BOMLevel
			,   xr.XQty
			,   xr.XScrap
			,	xr.Hierarchy
		from
			FT.XRt xr
			left join dbo.part_machine pmTopPrimary
				on pmTopPrimary.part = xr.TopPart
			left join dbo.part_machine pm
				on pm.part = xr.ChildPart
	)
,	onLineXR
	(	TopMachineCode, MachineCode, BOMStructure, XRtID, TopPartCode, ChildPartCode, BOMID, Sequence, BOMLevel, XQty, XScrap, Hierarchy
	)
as
	(	select
			*
		from
			xr
		where
			xr.TopMachineCode = xr.MachineCode
	)
,	inlineXR
	(	TopMachineCode, BOMStructure, TopPartCode, ChildPartCode, MachineCode, BOMID, XQty, XScrap, BOMLevel, LowLevel, Sequence, Hierarchy
	)
as
	(	select
			xr.TopMachineCode
		,	xr.BOMStructure
		,	xr.TopPartCode
		,	xr.ChildPartCode
		,	xr.MachineCode
		,	xr.BOMID
		,	xr.XQty
		,	xr.XScrap
		,	xr.BOMLevel
		,	LowLevel = (select max(xr1.BOMLevel) from xr xr1 where xr1.TopPartCode = xr.TopPartCode and xr1.ChildPartCode = xr.ChildPartCode)
		,	xr.Sequence
		,	xr.Hierarchy
		from
			onLineXR xr
		where
			not exists
				(	select
						MissingBOMLevel = ur.RowNumber
					from
						dbo.udf_Rows(xr.BOMLevel - 1) ur
					where
						not exists
							(	select
									*
								from
									onLineXR
								where
									onLineXR.TopPartCode = xr.TopPartCode
									and xr.Hierarchy like onLineXR.Hierarchy + '/%'
									and onLineXR.BOMLevel = ur.RowNumber
							)
				)
	)
select
	inlineXR.TopMachineCode
,   inlineXR.BOMStructure
,   inlineXR.TopPartCode
,   inlineXR.ChildPartCode
,   inlineXR.MachineCode
,   inlineXR.BOMID
,   inlineXR.XQty
,   inlineXR.XScrap
,   inlineXR.BOMLevel
,   inlineXR.LowLevel
,   inlineXR.Sequence
,	inlineXR.Hierarchy
,	InLineTemp = case
		when
			(	select
					count(*)
				from
					xr xr1
					join xr xr2
						on xr2.ChildPartCode = xr1.TopPartCode
						and xr2.TopPartCode = inlineXR.TopPartCode
				where
					xr2.Sequence > 0
					and xr1.Sequence > 0
					and xr1.Sequence = inlineXR.Sequence + xr2.Sequence
			 ) > 0 then 1
		else 0
	end
from
	inlineXR
where
	MachineCode is not null
go

