select
	*
from
	dbo.MES_JobList mjl
where
	mjl.MachineCode = 'OFFLINEA'
	and exists
		(	select
				*
			from
				dbo.fn_MES_GetJobBackflushDetails(mjl.WorkOrderNumber, 1, 6) bd
			where
				bd.QtyIssue > bd.QtyRequired
		)

select
	*
from
	dbo.fn_MES_GetJobBackflushDetails('WO_0000006548', 1, 6) bd
where
	bd.QtyIssue > bd.QtyRequired

select
	*
from
	dbo.MES_JobList mjl
where
	mjl.WorkOrderNumber = 'WO_0000006548'
