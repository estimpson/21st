SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_user_navigation_group_options] AS
SELECT
	user_navigation_groups.security_id,
	navigation_group_options.option_description,
	ISNULL(navigation_group_options.is_option_read_only, 'N') is_option_read_only,
	navigation_group_options.changed_date,
	navigation_group_options.changed_user_id
FROM
	user_navigation_groups INNER JOIN
	navigation_group_options ON
		user_navigation_groups.navigation_group = navigation_group_options.navigation_group
GO
