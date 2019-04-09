SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_menu_options] AS
SELECT
	vw_menu_items.menu_option,
	vw_menu_items.menu_option_application,
	vw_menu_items.menu_description menu_option_description,
	vw_menu_items.menu_option_enabled,
	CONVERT(VARCHAR(50), NULL) table_source
FROM
	vw_menu_items 
WHERE
	menu_option IS NOT NULL 
GO
