
/*
Create table fx21st.custom.WorkOrderDetailBOMVerification
*/

--use fx21st
--go

--drop table custom.WorkOrderDetailBOMVerification
if	objectproperty(object_id('custom.WorkOrderDetailBOMVerification'), 'IsTable') is null begin

	create table custom.WorkOrderDetailBOMVerification
	(	WorkOrderNumber varchar(50) not null
	,	WorkOrderDetailLine float not null default (0)
	,	Notes varchar(1000) null
	,	OperatorCode varchar(5) not null
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

