SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[Scheduling_NetRequirementsSummary]
as
select
	snrd.PrimaryMachineCode
,	snrd.BuildPartCode
,	snrd.OrderNo
,	snrd.BillToCode
,	snrd.ShipToCode
,	snrd.LowLevel
,	DueDT = min(case when snrd.QtyNetDue > 0 then snrd.RequiredDT end)
,	DaysOnHand = datediff(day, getdate(), min(case when snrd.QtyNetDue > 0 then snrd.RequiredDT end))
,	QtyTotalDue = sum(snrd.QtyTotalDue)
,	QtyAvailable = sum(snrd.QtyAvailable)
,	QtyAlreadyProduced = sum(snrd.QtyAlreadyProduced)
,	QtyNetDue = sum(snrd.QtyNetDue)
,	QtyBuildable = sum(snrd.QtyBuildable)
,	RunningWODID = min(snrd.RunningWODID)
,	QtyRunningBuild = sum(snrd.QtyRunningBuild)
,	NextWODID = min(snrd.NextWODID)
,	QtyNextBuild = sum(snrd.QtyNextBuild)
,	BoxLabel = max(snrd.BoxLabel)
,	PalletLabel = max(snrd.PalletLabel)
,	PackageType = max(snrd.PackageType)
,	snrd.TopPartCode
from
	dbo.Scheduling_NetRequirementsDetails snrd
group by
	snrd.PrimaryMachineCode
,	snrd.BuildPartCode
,	snrd.OrderNo
,	snrd.BillToCode
,	snrd.ShipToCode
,	snrd.LowLevel
,	snrd.TopPartCode
GO
