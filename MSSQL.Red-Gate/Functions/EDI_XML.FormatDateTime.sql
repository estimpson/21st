SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML].[FormatDateTime]
(	@dateTime datetime
,	@dateTimeFormat varchar(20)
)
returns varchar(20)
as
begin
--- <Body>
	declare
		@dateString varchar(20)

	set @dateString = EDI.udf_FormatDT(@dateTimeFormat, @dateTime)

--- </Body>

---	<Return>
	return
		@dateString
end

GO
