SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andre S. Boulanger
-- Create date: 2015-02-26
-- Description:	Returns last cost imported for WIP parts imported
-- =============================================
CREATE FUNCTION [custom].[fn_lastWIPCost] ()
RETURNS 
 @WIPCost TABLE 
(
	 Part VARCHAR(255)
	,Cost NUMERIC (20,6)
)
AS
BEGIN
	DECLARE @LastID TABLE
	(	part VARCHAR(255),
		ID INT
	)

	INSERT @LastID
	        ( part, ID )
	SELECT 
		part,
		MAX(RowID)
	FROM Custom.part_WIP_Imported
	GROUP BY
		part

	INSERT @WIPCost
	        ( Part, Cost )
	
	SELECT pwi.part,
		   COALESCE(pwi.price , 0)
	FROM
		custom.part_WIP_Imported pwi
	JOIN
		@LastID lid ON lid.part = pwi.Part AND lid.id = pwi.RowID
	
	RETURN 
END
GO
