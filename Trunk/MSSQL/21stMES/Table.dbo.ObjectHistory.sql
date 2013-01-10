
/*
Create table Fx.dbo.ObjectHistory
*/

--use Fx
--go

--drop table dbo.ObjectHistory
if	objectproperty(object_id('dbo.ObjectHistory'), 'IsTable') is null begin

	create table dbo.ObjectHistory
	(	SnapshotName varchar(255)
	,	SnapshotDate datetime
	,	SnapshotShift int
	,	Serial int not null
	,	Part varchar (25) not null
	,	Quantity numeric (20, 6) null
	,	StdQuantity numeric (20, 6) null
	,	Unit varchar (2) null
	,	PackageType varchar (20) null
	,	Location varchar (10) not null
	,	Status char (1) not null
	,	Lot varchar (20) null
	,	Note varchar (254) null
	,	RowID int identity(1,1) primary key clustered
	,	RowCreateDT datetime default(getdate())
	,	RowCreateUser sysname default(suser_name())
	,	RowModifiedDT datetime default(getdate())
	,	RowModifiedUser sysname default(suser_name())
	,	unique nonclustered
		(	SnapshotName
		,	Serial
		)
	)
end
go

