SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [EDI_XML_PLEX_ASN].[SEG_FOB]
(	@PaymentMethod char(2)
)
returns xml
as
begin
--- <Body>
	declare
		@xmlOutput xml

	set	@xmlOutput =
		(	select
				EDI_XML.SEG_INFO('004010', 'FOB')
			,	EDI_XML.DE('004010', '0146', @PaymentMethod)
			for xml raw ('SEG-FOB'), type
		)
--- </Body>

---	<Return>
	return
		@xmlOutput
end

GO
