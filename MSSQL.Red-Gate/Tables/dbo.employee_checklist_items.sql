CREATE TABLE [dbo].[employee_checklist_items]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[checklist_item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[completed_date] [datetime] NULL,
[checklist_notes] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_checklist_items] ADD CONSTRAINT [pk_employee_checklist_items] PRIMARY KEY CLUSTERED  ([employee], [checklist_item]) ON [PRIMARY]
GO
