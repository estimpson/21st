SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_user_validation] AS
SELECT
	user_names.security_id user_name,
	user_names.password,
	user_names.last_name,
	user_names.first_name,
	user_names.email_address,
	user_names.email_notification,
	user_names.membership_provider_username,
	CONVERT(CHAR(1), 'N') must_change_password,
	ISNULL(user_names.active_inactive, 'A') inactive,
	(SELECT TOP 1 employee FROM employees WHERE employees.security_id = user_names.security_id) employee
FROM
	user_names
GO
