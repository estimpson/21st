SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UserMenuOptions] @as_securityid varchar(25),
                                 @as_primarytablet varchar(25)

AS

-- 07-Oct-2008 Modified the LOJ of navigation_options to only select rows
--             where the navigation_tablet_options.option_type =
--             navigation_options.option_type.  This is necessary so that
--             only Windows (not tablets) get the window put into the
--             option_parameters.

-- 29-Aug-2008 Added script to add navigation tablets to the navigation
--             group options.

-- 13-Jun-2008 Added DISTINCT to the select for nonrestricted users to
--             eliminate duplicate menu options related to custom menus
--             at GUC.

-- 03-Feb-2007 Added join of installed_modules.

-- 12-Jan-2007 Added DISTINCT to the select for restricted users so
--             that menus aren't returned multiple times when they are
--             in multiple navigation_groups.

-- 29-Nov-2006 Return "N" as the value for menu_closed.

BEGIN

DECLARE @s_restricted CHAR(1),
        @i_cnt smallint

CREATE TABLE #user_menu_options
       (tablet varchar(25) NOT NULL,
       option_description varchar(50) NOT NULL,
       option_type char(1) NOT NULL,
       option_parameters varchar(255) NULL,
       option_help_message varchar(100) NULL,
       tablet_title varchar(50) NULL,
       option_level smallint NULL,
       tablet1 varchar(25) NULL,
       tablet2 varchar(25) NULL,
       tablet3 varchar(25) NULL,
       tablet4 varchar(25) NULL,
       tablet5 varchar(25) NULL,
       sort1 smallint NULL,
       sort2 smallint NULL,
       sort3 smallint NULL,
       sort4 smallint NULL,
       sort5 smallint NULL,
       menu char(1) NULL,
       menu_module varchar(25) NULL,
       menu_item_sort_order int NULL,
       menu_module_title varchar(50) NULL,
       menu_module_sort_order smallint NULL)

CREATE TABLE #nav_group_opts_with_tablets
       (navigation_group varchar(40) NOT NULL,
       tablet varchar(25) NOT NULL,
       option_description varchar(50) NOT NULL,
       option_type char(1) NOT NULL)


-- Populate a table with the hierarchy from navigation_tablet_options

INSERT INTO #user_menu_options
  SELECT navigation_tablet_options.tablet,
         navigation_tablet_options.option_description,
         navigation_tablet_options.option_type,
         navigation_options.option_parameters,
         navigation_options.option_help_message,
         '',1,
         navigation_tablet_options.tablet,'','','','',
         navigation_tablet_options.option_order,0,0,0,0,
         navigation_options.menu,
         navigation_options.menu_module,
         navigation_options.menu_item_sort_order,'',0
    FROM navigation_tablet_options
         JOIN installed_modules
           ON navigation_tablet_options.installed_module = installed_modules.installed_module
         LEFT OUTER JOIN navigation_options
                      ON navigation_tablet_options.option_description = navigation_options.option_description
                     AND navigation_tablet_options.option_type = navigation_options.option_type
   WHERE navigation_tablet_options.tablet = @as_primarytablet

INSERT INTO #user_menu_options
  SELECT navigation_tablet_options.tablet,
         navigation_tablet_options.option_description,
         navigation_tablet_options.option_type,
         navigation_options.option_parameters,
         navigation_options.option_help_message,
         '',2,
         #user_menu_options.tablet1,
         #user_menu_options.option_description,'','','',
         #user_menu_options.sort1,
         navigation_tablet_options.option_order,0,0,0,
         navigation_options.menu,
         navigation_options.menu_module,
         navigation_options.menu_item_sort_order,'',0
    FROM navigation_tablet_options
         JOIN installed_modules
           ON navigation_tablet_options.installed_module = installed_modules.installed_module
         LEFT OUTER JOIN navigation_options
                 ON navigation_tablet_options.option_description = navigation_options.option_description
                AND navigation_tablet_options.option_type = navigation_options.option_type,
         #user_menu_options
   WHERE #user_menu_options.option_type = 'T'
     AND #user_menu_options.option_level = 1
     AND navigation_tablet_options.tablet = #user_menu_options.option_description

INSERT INTO #user_menu_options
  SELECT navigation_tablet_options.tablet,
         navigation_tablet_options.option_description,
         navigation_tablet_options.option_type,
         navigation_options.option_parameters,
         navigation_options.option_help_message,
         '',3,
         #user_menu_options.tablet1,
         #user_menu_options.tablet2,
         #user_menu_options.option_description,'','',
         #user_menu_options.sort1,
         #user_menu_options.sort2,
         navigation_tablet_options.option_order,0,0,
         navigation_options.menu,
         navigation_options.menu_module,
         navigation_options.menu_item_sort_order,'',0
    FROM navigation_tablet_options
         JOIN installed_modules
           ON navigation_tablet_options.installed_module = installed_modules.installed_module
         LEFT OUTER JOIN navigation_options
                 ON navigation_tablet_options.option_description = navigation_options.option_description
                AND navigation_tablet_options.option_type = navigation_options.option_type,
         #user_menu_options
   WHERE #user_menu_options.option_type = 'T'
     AND #user_menu_options.option_level = 2
     AND navigation_tablet_options.tablet = #user_menu_options.option_description

INSERT INTO #user_menu_options
  SELECT navigation_tablet_options.tablet,
         navigation_tablet_options.option_description,
         navigation_tablet_options.option_type,
         navigation_options.option_parameters,
         navigation_options.option_help_message,
         '',4,
         #user_menu_options.tablet1,
         #user_menu_options.tablet2,
         #user_menu_options.tablet3,
         #user_menu_options.option_description,'',
         #user_menu_options.sort1,
         #user_menu_options.sort2,
         #user_menu_options.sort3,
         navigation_tablet_options.option_order,0,
         navigation_options.menu,
         navigation_options.menu_module,
         navigation_options.menu_item_sort_order,'',0
    FROM navigation_tablet_options
         JOIN installed_modules
           ON navigation_tablet_options.installed_module = installed_modules.installed_module
         LEFT OUTER JOIN navigation_options
                 ON navigation_tablet_options.option_description = navigation_options.option_description
                AND navigation_tablet_options.option_type = navigation_options.option_type,
         #user_menu_options
   WHERE #user_menu_options.option_type = 'T'
     AND #user_menu_options.option_level = 3
     AND navigation_tablet_options.tablet = #user_menu_options.option_description

INSERT INTO #user_menu_options
  SELECT navigation_tablet_options.tablet,
         navigation_tablet_options.option_description,
         navigation_tablet_options.option_type,
         navigation_options.option_parameters,
         navigation_options.option_help_message,
         '',5,
         #user_menu_options.tablet1,
         #user_menu_options.tablet2,
         #user_menu_options.tablet3,
         #user_menu_options.tablet4,
         #user_menu_options.option_description,
         #user_menu_options.sort1,
         #user_menu_options.sort2,
         #user_menu_options.sort3,
         #user_menu_options.sort4,
         navigation_tablet_options.option_order,
         navigation_options.menu,
         navigation_options.menu_module,
         navigation_options.menu_item_sort_order,'',0
    FROM navigation_tablet_options
         JOIN installed_modules
           ON navigation_tablet_options.installed_module = installed_modules.installed_module
         LEFT OUTER JOIN navigation_options
                 ON navigation_tablet_options.option_description = navigation_options.option_description
                AND navigation_tablet_options.option_type = navigation_options.option_type,
         #user_menu_options
   WHERE #user_menu_options.option_type = 'T'
     AND #user_menu_options.option_level = 4
     AND navigation_tablet_options.tablet = #user_menu_options.option_description

-- Add the table title to those options that are tablets.
UPDATE #user_menu_options
   SET tablet_title = (SELECT tablet_title FROM navigation_tablets
                        WHERE navigation_tablets.tablet = #user_menu_options.option_description)
 WHERE option_type = 'T'

-- Add the module title to those options that appear on CMC menus.
UPDATE #user_menu_options
   SET menu_module_title = IsNull((SELECT tablet_title FROM navigation_tablets
                        WHERE navigation_tablets.tablet = #user_menu_options.menu_module),
                        menu_module)
 WHERE option_type = 'W'
   AND IsNull(menu_module,'') <> ''

-- Add the module sort order to those options that appear on CMC menus.
UPDATE #user_menu_options
   SET menu_module_sort_order = IsNull((SELECT option_order FROM navigation_tablet_options
                        WHERE navigation_tablet_options.tablet = 'EMPOWER'
                          AND navigation_tablet_options.option_description = #user_menu_options.menu_module),
                        20)
 WHERE option_type = 'W'
   AND IsNull(menu_module,'') <> ''

-- See if this user is restricted to certain navigation options
SELECT @s_restricted = IsNull(restricted,'')
  FROM user_names
 WHERE security_id = @as_securityid

IF @@rowcount = 0 SELECT @s_restricted = 'N'

IF @s_restricted <> 'Y' AND @s_restricted <> 'N' SELECT @s_restricted = 'N'

IF @s_restricted = 'Y'
  BEGIN
    --  Add the navigation tablets to the navigation_group_options
    --  because the navigation_group_options no longer contain tablets.
    --  First select the options this user has access to.
    INSERT INTO #nav_group_opts_with_tablets
      SELECT user_navigation_groups.navigation_group,
             tablet, option_description, option_type
        FROM user_navigation_groups, navigation_group_options
       WHERE user_navigation_groups.security_id = @as_securityid
         AND navigation_group_options.navigation_group =
	         user_navigation_groups.navigation_group

    --  Add up to 5 levels of tablets.
    SELECT @i_cnt = 1

    WHILE @i_cnt < 6
      BEGIN
        SELECT @i_cnt = @i_cnt + 1
        INSERT INTO #nav_group_opts_with_tablets
          SELECT #nav_group_opts_with_tablets.navigation_group,
                 navigation_tablet_options.tablet,
                 #nav_group_opts_with_tablets.tablet,
                 'T'
            FROM #nav_group_opts_with_tablets,
                 navigation_tablet_options
           WHERE #nav_group_opts_with_tablets.tablet =
                     navigation_tablet_options.option_description
             AND navigation_tablet_options.option_type = 'T'
             AND NOT EXISTS (SELECT 1
                               FROM #nav_group_opts_with_tablets tempt
                              WHERE tempt.navigation_group =
                                      #nav_group_opts_with_tablets.navigation_group
                                AND tempt.option_description =
                                      #nav_group_opts_with_tablets.tablet
                                AND option_type = 'T')
           GROUP BY #nav_group_opts_with_tablets.navigation_group,
                 navigation_tablet_options.tablet,
                 #nav_group_opts_with_tablets.tablet
      END
   END

IF @s_restricted = 'N'
  SELECT DISTINCT tablet,
         option_description,
         option_type,
         option_parameters,
         option_help_message,
         tablet_title,
         option_level,
         tablet1,
         tablet2,
         tablet3,
         tablet4,
         tablet5,
         sort1,
         sort2,
         sort3,
         sort4,
         sort5,
         menu,
         menu_module,
         menu_item_sort_order,
         menu_module_title,
         menu_module_sort_order,
         'N'
    FROM #user_menu_options
   ORDER BY sort1,
            sort2,
            sort3,
            sort4,
            sort5
ELSE
  SELECT DISTINCT #user_menu_options.tablet,
         #user_menu_options.option_description,
         #user_menu_options.option_type,
         option_parameters,
         option_help_message,
         tablet_title,
         option_level,
         tablet1,
         tablet2,
         tablet3,
         tablet4,
         tablet5,
         sort1,
         sort2,
         sort3,
         sort4,
         sort5,
         menu,
         menu_module,
         menu_item_sort_order,
         menu_module_title,
         menu_module_sort_order,
         'N'
    FROM #user_menu_options, #nav_group_opts_with_tablets
   WHERE #nav_group_opts_with_tablets.tablet =
             #user_menu_options.tablet
     AND #nav_group_opts_with_tablets.option_description =
             #user_menu_options.option_description
     AND #nav_group_opts_with_tablets.option_type =
             #user_menu_options.option_type
   ORDER BY sort1,
            sort2,
            sort3,
            sort4,
            sort5
END
GO
