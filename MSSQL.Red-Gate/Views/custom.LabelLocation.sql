SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [custom].[LabelLocation]
as
select
	LabelLocation = datepart(year, getdate()) % 4
GO
