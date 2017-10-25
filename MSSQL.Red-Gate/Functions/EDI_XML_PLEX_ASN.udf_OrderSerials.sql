SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [EDI_XML_PLEX_ASN].[udf_OrderSerials]
(	@ShipperID INT
,	@CustomerPart VARCHAR(30)
,	@Packtype VARCHAR(25)
,	@PackQty NUMERIC(20,6)
)
RETURNS XML
AS
BEGIN
--- <Body>
	DECLARE
		@xmlOutput XML = ''

	DECLARE serialREFs CURSOR LOCAL FOR
	SELECT
		EDI_XML_V4010.SEG_REF('LS', ao.CustomerSerial)
	FROM
		EDI_XML_PLEX_ASN.ASNObjects ao
	WHERE
		ao.ShipperID = @ShipperID
		AND ao.CustomerPart = @CustomerPart
		AND ao.PackQty = @PackQty
		AND ao.PackageType = @Packtype

	OPEN serialREFs

	WHILE
		1 = 1 BEGIN

		DECLARE @segREF XML

		FETCH
			serialREFs
		INTO
			@segREF

		IF	@@FETCH_STATUS != 0 BEGIN
			BREAK
		END

		SET	@xmlOutput = CONVERT(VARCHAR(MAX), @xmlOutput) + CONVERT(VARCHAR(MAX), @segREF)
	END
--- </Body>

---	<Return>
	RETURN
		@xmlOutput
END


GO
