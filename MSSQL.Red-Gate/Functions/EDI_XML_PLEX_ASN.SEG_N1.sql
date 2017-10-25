SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_PLEX_ASN].[SEG_N1]
(	@entityIdentifierCode varchar(3)
,	@identificationQualifier varchar(3)
,	@identificationCode varchar(25)
,	@identificationName varchar(60)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO('004010', 'N1')
			,	EDI_XML.DE('004010', '0098', @entityIdentifierCode)
			,	EDI_XML.DE('004010', '0093', @identificationName)
			,	EDI_XML.DE('004010', '0066', @identificationQualifier)
			,	EDI_XML.DE('004010', '0067', @identificationCode)
			for xml raw ('SEG-N1'), type
		)
--- </Body>

---	<Return>
	return
		@xmlOutput
end

GO
