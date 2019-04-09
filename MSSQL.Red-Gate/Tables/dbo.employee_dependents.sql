CREATE TABLE [dbo].[employee_dependents]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dependent_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[first_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[relationship] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[home_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[work_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[birth_date] [datetime] NULL,
[student] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[handicapped] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[social_security] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[import_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_dependents] ADD CONSTRAINT [pk_employee_dependents] PRIMARY KEY CLUSTERED  ([employee], [dependent_id]) ON [PRIMARY]
GO
