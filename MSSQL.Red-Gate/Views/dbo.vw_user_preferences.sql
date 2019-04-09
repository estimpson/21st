SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_user_preferences] AS
SELECT
	preferences_user.security_id user_name,
	preferences_user.preference,
	preferences_user.value preference_value
FROM
	preferences_user
GO
