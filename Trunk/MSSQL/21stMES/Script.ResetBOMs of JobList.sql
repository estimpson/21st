declare
	@BomChangeParts varchar(max) = 'WPP-231, 19501'

declare
	jobList cursor read_only local for
select
	mjl.WorkOrderNumber
,	mjl.WorkOrderDetailLine
from
	dbo.MES_JobList mjl
where
	exists
		(
			select
				*
			from
				dbo.MES_JobBillOfMaterials mjbom
			where
				mjbom.WODID = mjl.WODID
				and mjbom.ChildPart in
				(
					select
						ltrim(rtrim(fsstr.Value))
					from
						dbo.fn_SplitStringToRows(@BomChangeParts, ',') fsstr
				)
		)

open jobList

while
	1 = 1 begin

	declare
		@WorkOrderNumber varchar(50)
	,	@WorkOrderDetailLine float

	fetch
		jobList
	into
		@WorkOrderNumber
	,	@WorkOrderDetailLine

	if	@@FETCH_STATUS != 0 begin
		break
	end

	begin transaction

	declare
		@TranDT datetime
	,	@Result int

	exec
		dbo.usp_WorkOrders_ReplaceWODBillOfMaterials
			@WorkOrderNumber = @WorkOrderNumber
		,	@WorkOrderDetailLine = @WorkOrderDetailLine
		,   @TranDT = @TranDT out
		,   @Result = @Result out

	commit transaction
end

close
	jobList

deallocate
	jobList

