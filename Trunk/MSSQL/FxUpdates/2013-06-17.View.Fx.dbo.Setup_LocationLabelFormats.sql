
/*
Create View.Fx.dbo.Setup_LocationLabelFormats.sql
*/

--use Fx
--go

--drop table dbo.Setup_LocationLabelFormats
if	objectproperty(object_id('dbo.Setup_LocationLabelFormats'), 'IsView') = 1 begin
	drop view dbo.Setup_LocationLabelFormats
end
go

create view dbo.Setup_LocationLabelFormats
as
select
	LabelName = rl.name
,	ReportName = rl.report
,	LabelType = rl.type
,	ObjectName = rl.object_name
,	LibraryName = rl.library_name
,	PrintPreview = rl.preview
,	PrintSetup = rl.print_setup
,	PrinterName = rl.printer
,	Copies = rl.copies
from
	dbo.report_library rl
where
	rl.report = 'Location Label'
go

select
	sllf.LabelName
,	sllf.ReportName
,	sllf.LabelType
,	sllf.ObjectName
,	sllf.LibraryName
,	sllf.PrintPreview
,	sllf.PrintSetup
,	sllf.PrinterName
,	sllf.Copies
from
	dbo.Setup_LocationLabelFormats sllf
order by
	sllf.LabelName
go

select
	LocationLabelFormat =
		(	select
				min(dbo.Setup_LocationLabelFormats.LabelName)
			from
				dbo.Setup_LocationLabelFormats
		)
go
