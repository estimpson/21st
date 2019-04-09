SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_user_menu_options] AS
SELECT
       user_names.security_id user_name,
       navigation_group_options.option_description menu_option,
       MAX(ISNULL(navigation_group_options.is_option_read_only, 'N')) read_only,
       CONVERT(CHAR(1), 'N') restrict_delete,
       CONVERT(VARCHAR(50), NULL) menu_option_tab,
       CONVERT(CHAR(1), 'N') menu_option_tab_disabled
FROM
       user_names INNER JOIN
       user_navigation_groups ON
              user_names.security_id = user_navigation_groups.security_id INNER JOIN
       navigation_group_options ON
              user_navigation_groups.navigation_group = navigation_group_options.navigation_group
GROUP BY
       user_names.security_id,
       navigation_group_options.option_description
UNION ALL
SELECT
       user_names.security_id user_name,
       navigation_options.option_description menu_option,
       'N' read_only,
       CONVERT(CHAR(1), 'N') restrict_delete,
       CONVERT(VARCHAR(50), NULL) menu_option_tab,
       CONVERT(CHAR(1), 'N') menu_option_tab_disabled
FROM
       user_names CROSS APPLY
       navigation_options
WHERE
       NOT EXISTS (SELECT 1 FROM user_navigation_groups WHERE security_id = user_names.security_id)
GROUP BY
       user_names.security_id,
       navigation_options.option_description
GO
