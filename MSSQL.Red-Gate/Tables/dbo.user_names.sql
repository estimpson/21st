CREATE TABLE [dbo].[user_names]
(
[security_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[password] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primary_tablet] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[restricted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_notification] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[membership_provider_username] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[last_activity_date] [datetime] NULL,
[secured_for_empower] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[secured_for_portal] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_id] [uniqueidentifier] NOT NULL CONSTRAINT [DF_user_names_user_id] DEFAULT (newid()),
[locked] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_UserNames]
   ON  [dbo].[user_names]
   AFTER DELETE
AS
BEGIN
	SET NOCOUNT ON;
	delete from user_secured_columns where security_id in (select security_id from deleted);
END
GO
ALTER TABLE [dbo].[user_names] ADD CONSTRAINT [pk_user_names] PRIMARY KEY CLUSTERED  ([security_id]) ON [PRIMARY]
GO
