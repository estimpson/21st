CREATE TABLE [dbo].[user_navigation_groups]
(
[security_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[navigation_group] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_UserNavigationGroups]
ON [dbo].[user_navigation_groups] FOR INSERT
AS

-- 25-Jun-09 Removed code that set user_names.security_enabled to 'Y'.  That
--           column has been obsoleted.

-- 03-Sep-08 Changed the id variables from string to uniqueidentifier in hopes
--           of solving a "Conversion failed when converting from a character
--           string to uniqueidentifier" error that Amy got when testing.  I can't
--           duplicate the error here when the variables are strings so I'm
--           not sure that I'm fixing the "real problem."

-- 25-Aug-08 Changed the valid values from blank to non-blank in the INSERT
--           into user_secured_columns.

-- 14-May-08 Need to create a row in EmpowerNET for the Role Employee Inquiry

BEGIN
DECLARE @i_rowcount int,
        @s_navigationgroup varchar(25),
        @s_securityid varchar(25),
        @u_userid uniqueidentifier,
        @u_roleid uniqueidentifier

  -- Make sure that we have a row in the inserted table for processing */
  SELECT @i_rowcount = Count(*) FROM inserted

  IF @i_rowcount > 0
    BEGIN

      DECLARE insusrnavgrpcursor CURSOR FOR
        SELECT navigation_group,
               security_id
          FROM inserted

      OPEN insusrnavgrpcursor

      WHILE 1 = 1
        BEGIN
          FETCH insusrnavgrpcursor
           INTO @s_navigationgroup, @s_securityid

          IF @@fetch_status <> 0 BREAK

          SELECT @i_rowcount = count(*)
            FROM navigation_group_options, navigation_options
           WHERE navigation_group_options.navigation_group = @s_navigationgroup
             AND navigation_group_options.option_description =
                     navigation_options.option_description
             AND navigation_options.option_parameters = 'w_employee_inquiry'
			 	
          IF @i_rowcount > 0
            -- User inserted a Navigation Group which includes the
            -- Navigation Option Employee Inquiry
            BEGIN
              -- see if the user already has an Employee Inquiry Role
              SELECT @i_rowcount = Count(*)
                FROM user_roles, user_names, roles
               WHERE user_names.security_id = @s_securityid
                 AND user_names.user_id = user_roles.user_id
                 AND user_roles.role_id = roles.role_id
                 AND roles.role_name = 'Employee Inquiry'

              IF @i_rowcount = 0
                -- we need to insert a row into user_roles
                BEGIN
                  -- Get the User ID for the inserted Security ID
                  SELECT @u_userid = user_id
                    FROM user_names
                   WHERE user_names.security_id = @s_securityid
                  -- Get the Role ID for the Employee Inquiry Role
                  SELECT @u_roleid = role_id
                    FROM roles
                   WHERE role_name = 'Employee Inquiry'
                  IF @u_userid is not null AND @u_roleid is not null
                     INSERT INTO user_roles
                         (user_id, role_id, changed_date, changed_user_id )
                       VALUES (@u_userid, @u_roleid, Getdate(), 'EMPOWER')
                END

              -- See if we need to insert a row for the EMPLOYEE column
              -- in user secured columns
              SELECT @i_rowcount = count(*)
                FROM user_secured_columns
               WHERE security_id = @s_securityid
                 AND secured_column_name = 'EMPLOYEE'

              IF @i_rowcount = 0
                BEGIN
                  INSERT INTO user_secured_columns
                      (security_id, secured_column_name,valid_values,
                       changed_date, changed_user_id, active_inactive)
                  VALUES ( @s_securityid, 'EMPLOYEE','REPLACE WITH LIST OF VALID EMPLOYEE IDS',
                       Getdate(), 'EMPOWER', 'A' )
                END
            END
        END
      CLOSE insusrnavgrpcursor
      DEALLOCATE insusrnavgrpcursor
    END
END
GO
ALTER TABLE [dbo].[user_navigation_groups] ADD CONSTRAINT [pk_user_navigation_groups] PRIMARY KEY CLUSTERED  ([security_id], [navigation_group]) ON [PRIMARY]
GO
