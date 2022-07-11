return

select
	*
from
	dbo.MES_JobList mjl
where
	mjl.PartCode = '52S-18-GSB-GSB-IN'

select
	*
from
	dbo.order_detail od
where
	od.part_number = '52S-18-GSB-GSB-IN'
go
return

create table
	#requirements
(	ID int not null IDENTITY(1, 1) primary key
,	PartCode varchar(25) not null
,	BillToCode varchar(10) null
,	RequiredDT datetime not null
,	QtyRequired numeric(20,6) not null
,	AccumRequired numeric(20,6)	null
)

declare
	@NOBILLTO char(4)

set	@NOBILLTO = '~~~~'

insert
	#requirements
(	PartCode
,	BillToCode
,	RequiredDT
,	QtyRequired
)
select
	PartCode = fmnm.Part
,	BillToCode = coalesce(oh.customer, @NOBILLTO)
,	RequiredDT = fmnm.RequiredDT
,	QtyRequired = fmnm.Balance
from
	dbo.fn_MES_NetMPS() fmnm
	left join dbo.order_header oh
		on oh.order_no = fmnm.OrderNo
		and oh.blanket_part = fmnm.Part
where
	fmnm.Part = '52S-18-GSB-GSB-IN'
order by
	fmnm.Part
,	oh.customer
,	fmnm.RequiredDT

update
	r
set
	AccumRequired =
	(	select
			sum(QtyRequired)
		from
			#requirements r1
		where
			r1.PartCode = r.PartCode
			and r1.BillToCode = r.BillToCode
			and r1.ID <= r.ID
	)
from
	#requirements r
go
declare
	@NOBILLTO char(4) = '~~~~'
,	@HorizonEndDT datetime = convert(datetime, '2022-01-10') + 42

select
	PartCode = coalesce(requirements.PartCode, jobsRunning.PartCode, jobsPlanning.PartCode)
,	BillToCode = nullif(coalesce(requirements.BillToCode, jobsRunning.BilltoCode, jobsPlanning.BilltoCode), @NOBILLTO)
,	PrimaryMachineCode = min(pmPrimary.machine)
,	RunningMachineCode = min(jobsRunning.RunningMachineCode)
,	NewPlanningQty = case when min(coalesce(jobsRunning.QtyScheduled, 0)) < sum(requirements.QtyRequired) then sum(requirements.QtyRequired) - min(coalesce(jobsRunning.QtyScheduled, 0)) else 0 end
,	NewPlanningDueDT = min(case when coalesce(jobsRunning.QtyScheduled, 0) < requirements.AccumRequired then requirements.RequiredDT end)
,	CurrentPlanningWODID = min(jobsPlanning.WODID)
,   CurrentPlanningQty = min(jobsPlanning.QtyScheduled)
,	min(requirements.RequiredDT)
,	min(@HorizonEndDT)
from
	#requirements requirements
	full join
	(	select
			wod.PartCode
		,	BillToCode = coalesce(wod.CustomerCode, @NOBILLTO)
		,	RunningMachineCode = coalesce(min(case when woh.MachineCode = pmPrimary.machine then woh.MachineCode end), min(case when woh.MachineCode != pmPrimary.machine then woh.MachineCode end))
		,	QtyScheduled = sum(case when wod.QtyLabelled > wod.QtyRequired then wod.QtyLabelled else wod.QtyRequired end - wod.QtyCompleted)
		from
			dbo.WorkOrderHeaders woh
			join dbo.WorkOrderDetails wod
				on wod.WorkOrderNumber = woh.WorkOrderNumber
			join dbo.part_machine pmPrimary
				on pmPrimary.part = wod.PartCode
				and pmPrimary.sequence = 1
		where
			woh.Status in
			(	select
	 				sd.StatusCode
	 			from
	 				FT.StatusDefn sd
	 			where
	 				sd.StatusTable = 'dbo.WorkOrderHeaders'
					and sd.StatusName in ('Running')
			)
		group by
			wod.PartCode
		,	wod.CustomerCode
	) jobsRunning
	on jobsRunning.PartCode = requirements.PartCode
		and jobsRunning.BillToCode = requirements.BillToCode
	full join
	(	select
			wod.PartCode
		,	BillToCode = coalesce(wod.CustomerCode, @NOBILLTO)
		,	WODID = max(wod.RowID)
		,	QtyScheduled = sum(wod.QtyRequired - wod.QtyCompleted)
		from
			dbo.WorkOrderHeaders woh
			join dbo.WorkOrderDetails wod
				on wod.WorkOrderNumber = woh.WorkOrderNumber
		where
			woh.Status in
			(	select
	 				sd.StatusCode
	 			from
	 				FT.StatusDefn sd
	 			where
	 				sd.StatusTable = 'dbo.WorkOrderHeaders'
	 				and sd.StatusName = 'New'
			)
		group by
			wod.PartCode
		,	wod.CustomerCode
	) jobsPlanning
	on jobsPlanning.PartCode = coalesce(requirements.PartCode, jobsRunning.PartCode)
		and jobsPlanning.BillToCode = coalesce(requirements.BillToCode, jobsRunning.BillToCode)
	join dbo.part_machine pmPrimary
		on pmPrimary.part = coalesce(requirements.PartCode, jobsRunning.PartCode, jobsPlanning.PartCode)
		and pmPrimary.sequence = 1
	left join dbo.MES_MachinePlanningHorizon mmph
		on mmph.MachineCode = pmPrimary.machine
where
	1 = 1
	and coalesce(requirements.PartCode, jobsRunning.PartCode, jobsPlanning.PartCode) = '52S-18-GSB-GSB-IN'
	and case when coalesce(jobsRunning.QtyScheduled, 0) < requirements.AccumRequired then requirements.RequiredDT end < coalesce(convert(datetime, '2022-01-10') + mmph.HorizonDays, @HorizonEndDT)
group by
	coalesce(requirements.PartCode, jobsRunning.PartCode, jobsPlanning.PartCode)
,	coalesce(requirements.BillToCode, jobsRunning.BilltoCode, jobsPlanning.BillToCode)

select
	*
from
	dbo.MES_MachinePlanningHorizon mmph
