
/*
Create table fx21st.custom.WorkOrderDetailMattecSchedule
*/

--use fx21st
--go

--drop table custom.WorkOrderDetailMattecSchedule
if	objectproperty(object_id('custom.WorkOrderDetailMattecSchedule'), 'IsTable') is null begin

	create table custom.WorkOrderDetailMattecSchedule
	(	WorkOrderNumber varchar(50) not null
	,	WorkOrderDetailLine float not null default (0)
	,	MattecJobNumber varchar(50) null
	,	QtyMattec numeric(20,6) null
	,	RowCreateDT datetime default(getdate())
	,	RowCreateUser sysname default(suser_name())
	,	RowModifiedDT datetime default(getdate())
	,	RowModifiedUser sysname default(suser_name())
	,	primary key
		(	WorkOrderNumber
		,	WorkOrderDetailLine
		)
	,	foreign key
		(	WorkOrderNumber
		,	WorkOrderDetailLine
		) references dbo.WorkOrderDetails
		(	WorkOrderNumber
		,	Line
		) on delete cascade on update cascade
	)
end
go

/*
begin transaction
go

exec sp_rename 'custom.WorkOrderDetailMattecSchedule', 'WorkOrderDetailMattecSchedule_bk'
go

--drop table custom.WorkOrderDetailMattecSchedule
if	objectproperty(object_id('custom.WorkOrderDetailMattecSchedule'), 'IsTable') is null begin

	create table custom.WorkOrderDetailMattecSchedule
	(	WorkOrderNumber varchar(50) not null
	,	WorkOrderDetailLine float not null default (0)
	,	MattecJobNumber varchar(50) null
	,	QtyMattec numeric(20,6) null
	,	RowCreateDT datetime default(getdate())
	,	RowCreateUser sysname default(suser_name())
	,	RowModifiedDT datetime default(getdate())
	,	RowModifiedUser sysname default(suser_name())
	,	primary key
		(	WorkOrderNumber
		,	WorkOrderDetailLine
		)
	,	foreign key
		(	WorkOrderNumber
		,	WorkOrderDetailLine
		) references dbo.WorkOrderDetails
		(	WorkOrderNumber
		,	Line
		) on delete cascade on update cascade
	)
end
go

insert
	custom.WorkOrderDetailMattecSchedule
(	WorkOrderNumber
,	WorkOrderDetailLine
,	MattecJobNumber
,	QtyMattec
,	RowCreateDT
,	RowCreateUser
,	RowModifiedDT
,	RowModifiedUser
)
select
	WorkOrderNumber
,	WorkOrderDetailLine
,	MattecJobNumber = right(WorkOrderNumber, 3)
,	QtyMattec
,	RowCreateDT
,	RowCreateUser
,	RowModifiedDT
,	RowModifiedUser
from
	custom.WorkOrderDetailMattecSchedule_bk
go

select
	*
from
	custom.WorkOrderDetailMattecSchedule
go

--commit
rollback
go

drop table
	custom.WorkOrderDetailMattecSchedule_bk
go
*/

