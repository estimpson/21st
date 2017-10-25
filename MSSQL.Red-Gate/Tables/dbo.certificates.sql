CREATE TABLE [dbo].[certificates]
(
[certificate] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[curriculum] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceu_units] [decimal] (18, 6) NULL,
[class_hours] [decimal] (18, 6) NULL,
[prerequisite] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[certificates] ADD CONSTRAINT [pk_certificates] PRIMARY KEY CLUSTERED  ([certificate]) ON [PRIMARY]
GO
