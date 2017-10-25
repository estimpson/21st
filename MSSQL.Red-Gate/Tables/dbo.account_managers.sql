CREATE TABLE [dbo].[account_managers]
(
[account_manager] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[account_manager_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[commission_percent] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[account_managers] ADD CONSTRAINT [pk_account_managers] PRIMARY KEY CLUSTERED  ([account_manager]) ON [PRIMARY]
GO
