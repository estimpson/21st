SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_user_names] AS
SELECT
	user_names.security_id user_name,
	user_names.first_name,
	user_names.last_name,
	LTRIM(RTRIM(ISNULL(user_names.first_name, '') + ' ' + ISNULL(user_names.last_name, ''))) user_name_description,
	user_names.email_address,
	user_names.email_notification
FROM
	user_names 
GO
