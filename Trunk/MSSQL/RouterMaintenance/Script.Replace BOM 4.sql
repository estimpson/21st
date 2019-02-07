select
	mbjs.WorkOrderNumber
,	mbjs.WODID
,	mbjs.WorkOrderDetailLine
,	mbjs.WODBOMID
,	mbjs.ParentPartCode
,	mbjs.PrimaryPartCode
,	mbjs.PrimaryCommodity
,	mbjs.PrimaryDescription
,	mbjs.PrimaryXQty
,	mbjs.PrimaryXScrap
,	mbjs.PrimaryBOMID
,	mbjs.SubstitutePartCode
,	mbjs.SubstituteCommodity
,	mbjs.SubstituteDescription
,	mbjs.SubstituteXQty
,	mbjs.SubstituteXScrap
,	mbjs.SubstituteBOMID
,	mbjs.SubstitutionType
,	mbjs.SubstitutionRate
from
	dbo.MES_BOMJobSubstitution mbjs
where
	mbjs.WODID = 43027

select
	*
from
	dbo.WorkOrderHeaders woh
where
	woh.WorkOrderNumber = 'WO_0000040287'