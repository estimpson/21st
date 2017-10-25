CREATE TABLE [dbo].[applications]
(
[application] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[application_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[applications] ADD CONSTRAINT [pk_applications] PRIMARY KEY CLUSTERED  ([application]) ON [PRIMARY]
GO
