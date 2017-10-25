CREATE TABLE [dbo].[cost_identifier_classes]
(
[cost_id_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cost_id_class_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_identifier_classes] ADD CONSTRAINT [pk_cost_identifier_classes] PRIMARY KEY CLUSTERED  ([cost_id_class]) ON [PRIMARY]
GO
