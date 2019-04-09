CREATE TABLE [dbo].[email_logs]
(
[email_log] [int] NOT NULL IDENTITY(1, 1),
[email_date] [datetime] NULL,
[email_subect] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_body] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_to] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[error_message] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[email_logs] ADD CONSTRAINT [pk_email_logs] PRIMARY KEY CLUSTERED  ([email_log]) ON [PRIMARY]
GO
