CREATE TABLE [dbo].[fa_classes]
(
[fa_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fa_class_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[personal_real] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[own_lease] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_classes] ADD CONSTRAINT [pk_fa_classes] PRIMARY KEY CLUSTERED  ([fa_class]) ON [PRIMARY]
GO
