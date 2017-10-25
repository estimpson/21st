CREATE TABLE [dbo].[eeoc_classes]
(
[eeoc_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[eeoc_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eeoc_classes] ADD CONSTRAINT [pk_eeoc_classes] PRIMARY KEY CLUSTERED  ([eeoc_class]) ON [PRIMARY]
GO
