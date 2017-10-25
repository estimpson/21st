CREATE TABLE [dbo].[label_objects]
(
[label_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[label_object] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[labels_per_page] [smallint] NULL,
[label_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[label_objects] ADD CONSTRAINT [pk_label_objects] PRIMARY KEY NONCLUSTERED  ([label_name]) ON [PRIMARY]
GO
