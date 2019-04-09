CREATE TABLE [dbo].[checklist_items]
(
[checklist_item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[checklist_item_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[checklist_items] ADD CONSTRAINT [pk_checklist_items] PRIMARY KEY CLUSTERED  ([checklist_item]) ON [PRIMARY]
GO
