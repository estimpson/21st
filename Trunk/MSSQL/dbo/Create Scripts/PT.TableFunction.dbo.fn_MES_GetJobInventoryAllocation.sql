
--use fx21st
--go

if	objectproperty(object_id('dbo.fn_MES_GetJobInventoryAllocation'), 'IsTableFunction') = 1 begin
	drop function dbo.fn_MES_GetJobInventoryAllocation
end
go

create function dbo.fn_MES_GetJobInventoryAllocation
(	@WorkOrderNumber varchar(50)
,	@WorkOrderDetailLine int
,	@XRt dbo.MES_XRt readonly
)
returns
	@InventoryAlloc table
	(	RowID int not null IDENTITY(1, 1) primary key
	,	Serial int
	,	Part varchar (25)
	,	Suffix int
	,	AllocationDT datetime
	,	QtyOriginal float
	,	QtyAvailable float
	,	QtyPer int
	,	QtyIssue float default 0
	,	QtyOverage float default 0
	,	PriorAccum float
	,	Concurrence tinyint
	,	LastAllocation tinyint
	)
as
begin
--- <Body>
	insert
		@InventoryAlloc
	(	Serial
	,	Part
	,	Suffix
	,	AllocationDT
	,	QtyOriginal
	,	QtyAvailable
	,	QtyPer
	)
	select
		Serial = coalesce(oAvailable.Serial, -1)
	,	Part = xr.ChildPart
	,	Suffix = coalesce (xr.Suffix, -1)
	,	AllocationDT = coalesce
		(	(	select
					max(atTransfer.date_stamp)
				from
					dbo.audit_trail atTransfer
				where
					atTransfer.Serial = oAvailable.Serial
					and atTransfer.type = 'T'
			)
		,	(	select
					max(atBreak.date_stamp)
				from
					dbo.audit_trail atBreak
				where
					atBreak.Serial = oAvailable.Serial
					and atBreak.type = 'B'
			)
		,	getdate()
		)
	,	QtyOriginal = null
	,	QtyAvailable = coalesce(oAvailable.QtyAvailable, 0)
	,	QtyPer = null
	from
		(	select
				ChildPart
			,	Suffix
			from
				@XRt
			group by
				ChildPart
			,	Suffix
		) xr
		left join
		(	select
				Serial = o.serial
			,	PartCode = o.part
			,	LocationCode = o.location
			,	QtyAvailable = o.std_quantity
			from
				dbo.object o
			where
				o.status = 'A'
		) oAvailable
			on oAvailable.PartCode = xr.ChildPart
			and coalesce(null, -1) = coalesce(xr.Suffix, -1)
		left join dbo.MES_SetupBackflushingPrinciples msbp
			on msbp.Type = 3
			and msbp.ID = oAvailable.PartCode
			and msbp.BackflushingPrinciple != 0 --(select dbo.udf_TypeValue('dbo.MES_SetupBackflushingPrinciples', 'BackflushingPrinciple', 'No Backflush'))
		left join dbo.MES_StagingLocations msl
			on msbp.BackflushingPrinciple = 3 --StagingLocation
			and msl.PartCode = oAvailable.PartCode
			and msl.StagingLocationCode = oAvailable.LocationCode
		left join dbo.location lGroupTechActive
			join dbo.location lGroupMachines
				on lGroupTechActive.group_no = lGroupMachines.group_no
			on msbp.BackflushingPrinciple = 4 --GroupTechnology (sequence)
			and lGroupTechActive.code = oAvailable.LocationCode
			and lGroupTechActive.sequence > 0
		left join dbo.location lPlant
			join dbo.location lPlantMachines -- All the machines within the inventory's plant.
				on coalesce(lPlantMachines.plant, 'N/A') = coalesce(lPlant.plant, 'N/A')
			on msbp.BackflushingPrinciple = 5 --(select dbo.udf_TypeValue('dbo.MES_SetupBackflushingPrinciples', 'BackflushingPrinciple, 'Plant'))
			and lPlant.code = oAvailable.LocationCode
		join dbo.WorkOrderDetails wod
			join dbo.WorkOrderHeaders woh
				on woh.WorkOrderNumber = wod.WorkOrderNumber
			on wod.WorkOrderNumber = @WorkOrderNumber
			and wod.Line = @WorkOrderDetailLine
			and woh.MachineCode = coalesce(lGroupMachines.code, msl.MachineCode, oAvailable.LocationCode)
		join dbo.machine m
			on m.machine_no = coalesce(lGroupMachines.code, lPlantMachines.code, msl.MachineCode, oAvailable.LocationCode)
			and m.machine_no = woh.MachineCode
	order by
		Part
	,	Suffix
	,	AllocationDT

	update
		ia
	set
		Concurrence = (select count(*) from @InventoryAlloc iaP where iaP.Serial = ia.Serial and iaP.Part = ia.Part)
	from
		@InventoryAlloc ia

	update
		ia
	set
		PriorAccum = coalesce((select sum(QtyAvailable / Concurrence) from @InventoryAlloc iaP where iaP.Part = ia.Part and iap.RowID < ia.RowID and coalesce(iaP.Suffix, -1) = coalesce(ia.Suffix, -1)), 0)
	,	LastAllocation = coalesce((select min(0) from @InventoryAlloc iaP where iaP.Part = ia.Part and iap.RowID > ia.RowID and coalesce(iaP.Suffix, -1) = coalesce(ia.Suffix, -1)), 1)
	from
		@InventoryAlloc ia
--- </Body>

---	<Return>
	return
end
go

