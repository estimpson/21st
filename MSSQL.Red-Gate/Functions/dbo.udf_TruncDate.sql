SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE function [dbo].[udf_TruncDate]
(	@DatePart nvarchar (25),
	@ArgDT datetime)
returns datetime
begin
	declare @ReturnDT datetime
	set	@ReturnDT = dbo.udf_DateAdd (@DatePart, dbo.udf_DateDiff (@DatePart, '1995-01-01', @ArgDT), '1995-01-01')
	return	@ReturnDT
end
GO
