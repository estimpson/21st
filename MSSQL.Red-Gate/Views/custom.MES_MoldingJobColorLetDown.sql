SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [custom].[MES_MoldingJobColorLetDown]
as
select
	mjbomBase.WorkOrderNumber
,	mjbomBase.WODID
,	mjbomBase.WorkOrderDetailLine
,	mcl.BaseMaterialCode
,	mcl.ColorantCode
,	StdLetDownRate = mcl.LetDownRate
,	JobLetDownRate = mjbomColorant.XQty / (mjbomBase.XQty + mjbomColorant.XQty)
,	PieceWeight = (mjbomBase.XQty + mjbomColorant.XQty)
,	BaseMaterialWeight = mjbomBase.XQty
,	ColorantWeight = mjbomColorant.XQty
,	BaseMaterialWODBOMID = mjbomBase.WODBOMID
,	BaseMaterialBOMID = mjbomBase.BillOfMaterialID
,	ColorantMaterialWODBOMID = mjbomColorant.WODBOMID
,	ColorantMaterialBOMID = mjbomColorant.BillOfMaterialID
from
	dbo.MES_JobBillOfMaterials mjbomBase
	join custom.MoldingColorLetdown mcl
		join dbo.MES_JobBillOfMaterials mjbomColorant
			on mjbomColorant.ChildPart = mcl.ColorantCode
		on mcl.BaseMaterialCode = mjbomBase.ChildPart
		and mjbomColorant.WODID = mjbomBase.WODID
GO
