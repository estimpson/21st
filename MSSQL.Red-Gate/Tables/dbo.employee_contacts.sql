CREATE TABLE [dbo].[employee_contacts]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[contact] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[contact_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primary_contact] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employee_emergency_contact_line] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_contacts] ADD CONSTRAINT [pk_employee_contacts] PRIMARY KEY NONCLUSTERED  ([employee], [contact]) ON [PRIMARY]
GO
