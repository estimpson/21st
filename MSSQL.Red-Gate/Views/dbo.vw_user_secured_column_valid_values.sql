SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_user_secured_column_valid_values] AS
SELECT
	user_secured_columns.security_id user_name,
	secured_columns.net_secured_column secured_column,
	user_secured_columns.valid_values,
	secured_columns.secured_column_length,
	secured_columns.secured_column_start
FROM
	user_secured_columns INNER JOIN
	secured_columns ON
		user_secured_columns.secured_column_name = secured_columns.secured_column_name 
WHERE
	ISNULL(secured_columns.active_inactive, 'A') = 'A' AND
	EXISTS (SELECT 1 FROM installed_modules WHERE installed_module = secured_columns.installed_module) AND
	secured_columns.net_secured_column IS NOT NULL
GO
