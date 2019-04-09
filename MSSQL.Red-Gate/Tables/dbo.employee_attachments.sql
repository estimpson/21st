CREATE TABLE [dbo].[employee_attachments]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[employee_attachment_id] [int] NOT NULL IDENTITY(1, 1),
[attachment_description] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[calendar_year] [int] NULL,
[file_id] [uniqueidentifier] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_visible_for_employee] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_attachments] ADD CONSTRAINT [pk_employee_attachments] PRIMARY KEY CLUSTERED  ([employee], [employee_attachment_id]) ON [PRIMARY]
GO
