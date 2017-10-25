begin transaction
go

--- <Update rows="*">
update
	pm
set
	machine = '5'
from
	dbo.part_machine pm
where
	machine = '3'

update
	woh
set
	MachineCode = '5'
from
	dbo.WorkOrderHeaders woh
where
	MachineCode = '3'
	and woh.Status in (0, 1)

update
	o
set
	location = '5'
from
	dbo.object o
where
	o.location = '3'

update
	msl
set
	StagingLocationCode = '5'
from
	dbo.MES_StagingLocations msl
where
	msl.StagingLocationCode = '3'

go

commit
go

