
/*
Create View.Fx.dbo.ReportLibrary_ReportTypeList.sql
*/

--use Fx
--go

--drop table dbo.ReportLibrary_ReportTypeList
if	objectproperty(object_id('dbo.ReportLibrary_ReportTypeList'), 'IsView') = 1 begin
	drop view dbo.ReportLibrary_ReportTypeList
end
go

create view dbo.ReportLibrary_ReportTypeList
as
select
	ReportType = rl.report
,   Description = rl.description
,	ReportCount =
		(	select
				count(*)
			from
				dbo.report_library rlib
			where
				rlib.report = rl.report
		)
from
	dbo.report_list rl
go

select
	rlrtl.ReportType
,   rlrtl.Description
,   rlrtl.ReportCount
from
	dbo.ReportLibrary_ReportTypeList rlrtl
order by
	rlrtl.ReportType
go
