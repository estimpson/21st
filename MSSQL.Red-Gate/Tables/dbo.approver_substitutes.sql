CREATE TABLE [dbo].[approver_substitutes]
(
[approver] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[approver_substitute] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[start_date] [datetime] NOT NULL,
[end_date] [datetime] NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[approver_substitutes] ADD CONSTRAINT [pk_approver_substitutes] PRIMARY KEY CLUSTERED  ([approver], [approver_substitute], [start_date]) ON [PRIMARY]
GO
