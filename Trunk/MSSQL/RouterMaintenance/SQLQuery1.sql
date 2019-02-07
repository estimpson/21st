select
	*
from
	dbo.MES_JobList mjl
	join dbo.MES_JobBillOfMaterials mjbom
		on mjbom.WODID = mjl.WODID
where
	mjbom.ChildPart = 'SB786'