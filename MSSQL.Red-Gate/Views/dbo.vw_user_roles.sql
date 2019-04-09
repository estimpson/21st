SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_user_roles] AS
SELECT
	user_names.security_id user_name,
	'ADMINISTRATORS' role
FROM
	user_names 
WHERE
	user_names.security_id = 'DBA'
UNION ALL
SELECT
	user_names.security_id user_name,
	'WEB ADMINISTRATORS' role
FROM
	user_names INNER JOIN
	web_administrators ON
		user_names.security_id = web_administrators.web_administrator
GO
