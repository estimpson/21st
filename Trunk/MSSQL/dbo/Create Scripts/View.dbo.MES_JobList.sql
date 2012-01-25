
/*
Create view fx21st.dbo.MES_JobList
*/

--use fx21st
--go

--drop table dbo.MES_JobList
if	objectproperty(object_id('dbo.MES_JobList'), 'IsView') = 1 begin
	drop view dbo.MES_JobList
end
go

create view dbo.MES_JobList
as
select
	WODID = wod.RowID
,	WorkOrderNumber = woh.WorkOrderNumber
,	WorkOrderStatus = woh.Status
,	WorkOrderType = woh.Type
,	MachineCode = woh.MachineCode
,	WorkOrderDetailLine = wod.Line
,	WorkOrderDetailStatus = wod.Status
,	wod.PartCode
,	WorkOrderDetailSequence = wod.Sequence
,	DueDT = wod.DueDT
,	QtyRequired = coalesce(wodms.QtyMattec, wod.QtyRequired)
,	QtyLabelled = wod.QtyLabelled
,	QtyCompleted = wod.QtyCompleted
,	QtyDefect = wod.QtyDefect
,	PackageType = pp.code
,	StandardPack = coalesce(pp.quantity, oh.standard_pack, pi.standard_pack) --Use the order's standard pack, the default standard pack for the package type, or the standard pack for the part.
,	NewBoxesRequired = case when coalesce(wodms.QtyMattec, wod.QtyRequired) > wod.QtyLabelled then ceiling((coalesce(wodms.QtyMattec, wod.QtyRequired) - wod.QtyLabelled) / coalesce(pp.quantity, oh.standard_pack, pi.standard_pack)) else 0 end
,	BoxLabelFormat = coalesce(od.box_label, oh.box_label, pp.label_format, pi.label_format)
,	BoxesLabelled = coalesce(boxes.BoxesLabelled, 0)
,	BoxesCompleted = coalesce(boxes.BoxesCompleted, 0)
,	BoxesCompletedNotPutaway = coalesce(boxes.BoxesCompletedNotPutAway, 0)
,	StartDT = wod.StartDT
,	EndDT = wod.EndDT
,	ShipperID = wod.ShipperID
,	BillToCode = wod.CustomerCode
from
	dbo.WorkOrderHeaders woh
		join dbo.WorkOrderDetails wod
			on wod.WorkOrderNumber = woh.WorkOrderNumber
		left join custom.WorkOrderDetailMattecSchedule wodms
			on wodms.WorkOrderNumber = wod.WorkOrderNumber
			and wodms.WorkOrderDetailLine = wod.Line
		left join dbo.order_header oh
			on oh.order_no = wod.SalesOrderNumber 
		left join dbo.order_detail od
			on od.id =
			(	select
					min(od1.id)
				from
					dbo.order_detail od1
				where
					od1.order_no = wod.SalesOrderNumber
					and od1.part_number = wod.PartCode
			)
		left join
		(	select
				woo.WorkOrderNumber
			,	woo.WorkOrderDetailLine
			,	BoxesLabelled = count(*)
			,	BoxesCompleted = count(woo.CompletionDT)
			,	PackageType = min(woo.PackageType)
			,	BoxesCompletedNotPutAway = count(case when o.serial is not null then woo.CompletionDT end)
			from
				dbo.WorkOrderObjects woo
				left join dbo.object o
					join dbo.machine m
						on o.location = m.machine_no
					on o.serial = woo.Serial
			where
				woo.Status in
					(	select
							sd.StatusCode
						from
							FT.StatusDefn sd
						where
							sd.StatusTable = 'dbo.WorkOrderObjects'
							and sd.StatusName in ('New', 'Completed')
					)
			group by
				woo.WorkOrderNumber
			,	woo.WorkOrderDetailLine
		) boxes
			on boxes.WorkOrderNumber = wod.WorkOrderNumber
			and boxes.WorkOrderDetailLine = wod.Line
	join dbo.part_inventory pi
		on wod.PartCode = pi.part
/*	Get the package type by precedence:
		1. Boxes already labelled
		2. Order's specified package type
		3. Correct package type for the order's standard pack.
		4. Correct package type for the part's standard pack.
*/
	left join dbo.part_packaging pp
		on pp.part = wod.PartCode
		and pp.code = coalesce
		(	boxes.PackageType
		,	oh.package_type
		,	(	select
					min(code)
				from
					dbo.part_packaging pp2
				where
					pp2.part = wod.PartCode
					and
					(	pp2.code = boxes.PackageType
						or pp2.quantity = coalesce(oh.standard_pack, pi.standard_pack)
					)
			)
		)
where
	woh.Status in
	(	select
			sd.StatusCode
		from
			FT.StatusDefn sd
		where
			sd.StatusTable = 'dbo.WorkOrderHeaders'
			and sd.StatusName in ('Open', 'Hold', 'New', 'Running')
	 )
	 and wod.Status in
	 (	select
	 		sd.StatusCode
	 	from
	 		FT.StatusDefn sd
	 	where
	 		sd.StatusTable = 'dbo.WorkOrderDetails'
			and sd.StatusName in ('Open', 'Hold', 'New', 'Running')
	 )
go

select
	*
from
	dbo.MES_JobList
