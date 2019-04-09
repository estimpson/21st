SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_preferences] AS
SELECT
	preference,
	preferences_standard.value preference_value,
	preferences_standard.user_changeable user_assignable
FROM
	preferences_standard 
WHERE
	EXISTS (SELECT 1 FROM installed_modules WHERE installed_module = preferences_standard.installed_module)

GO
