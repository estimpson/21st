SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_menu_items] AS
SELECT
	UPPER(ISNULL('GP_' + t1.tablet, navigation_tablet_options.option_description)) menu,
	ISNULL(t1.tablet_title, navigation_tablet_options.option_description) menu_description,
	UPPER(CASE navigation_tablet_options.option_type WHEN 'T' THEN NULL ELSE navigation_tablet_options.option_description END) menu_option,
	'GP_' + navigation_tablets.tablet parent_menu,
	navigation_tablet_options.option_order sort_line,
	CONVERT(CHAR(1), 'Y') menu_option_enabled,
	navigation_options.option_parameters menu_option_application
FROM
	navigation_tablets LEFT OUTER JOIN
	navigation_tablet_options ON
		navigation_tablets.tablet = navigation_tablet_options.tablet LEFT OUTER JOIN
	navigation_options ON
		navigation_tablet_options.option_description = navigation_options.option_description LEFT OUTER JOIN
	navigation_tablets t1 ON
		navigation_tablet_options.option_description = t1.tablet AND
		navigation_tablet_options.option_type = 'T'
WHERE
	EXISTS (SELECT 1 FROM installed_modules WHERE installed_module = navigation_tablet_options.installed_module)
UNION ALL
SELECT
	'GP_' + navigation_tablets.tablet,
	navigation_tablets.tablet_title menu_description,
	NULL menu_option,
	NULL parent_menu,
	1 sort_line,
	CONVERT(CHAR(1), 'Y') menu_option_enabled,
	NULL menu_option_application
FROM
	navigation_tablets
WHERE
	NOT EXISTS (SELECT 1 FROM navigation_tablet_options WHERE option_description = navigation_tablets.tablet)
GO
