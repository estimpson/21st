SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_PLEX_ASN].[SEG_LIN]
(	@assignedIdentification varchar(20)
,	@productQualifier varchar(3)
,	@productNumber varchar(25)
,	@productQualifier2 varchar(3)
,	@productNumber2 varchar(25)
,	@productQualifier3 varchar(3)
,	@productNumber3 varchar(25)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML_V4010.SEG_INFO('LIN')
			,	EDI_XML_V4010.DE('0350', @assignedIdentification)
			,	EDI_XML_V4010.DE('0235', @productQualifier)
			,	EDI_XML_V4010.DE('0234', @productNumber)
			,	EDI_XML_V4010.DE('0235', @productQualifier2)
			,	EDI_XML_V4010.DE('0234', @productNumber2)
			,	EDI_XML_V4010.DE('0235', @productQualifier3)
			,	EDI_XML_V4010.DE('0234', @productNumber3)
			for xml raw ('SEG-LIN'), type
		)
--- </Body>

---	<Return>
	return
		@xmlOutput
end

GO
