SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_web_navigation_options] AS
SELECT
	ISNULL(t1.tablet, navigation_tablet_options.option_description) option_description,
	navigation_tablets.tablet parent_option_description,
	ISNULL(t1.tablet_title, navigation_tablet_options.option_description) option_description_title,
	navigation_tablet_options.option_order,
	navigation_tablet_options.option_type,
	navigation_options.option_parameters,
	navigation_tablet_options.changed_date,
	navigation_tablet_options.changed_user_id
FROM
	navigation_tablets INNER JOIN
	navigation_tablet_options ON
		navigation_tablets.tablet = navigation_tablet_options.tablet LEFT OUTER JOIN
	navigation_options ON
		navigation_tablet_options.option_description = navigation_options.option_description LEFT OUTER JOIN
	navigation_tablets t1 ON
		navigation_tablet_options.option_description = t1.tablet AND
		navigation_tablet_options.option_type = 'T'
WHERE
	navigation_tablet_options.installed_module = 'EMWEB' AND
	EXISTS (SELECT 1 FROM installed_modules WHERE installed_module = navigation_tablet_options.installed_module)
GO
