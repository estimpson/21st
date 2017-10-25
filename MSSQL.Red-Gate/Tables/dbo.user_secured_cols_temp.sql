CREATE TABLE [dbo].[user_secured_cols_temp]
(
[security_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[column_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[report_security_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[column_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_secured_cols_temp] ADD CONSTRAINT [pk_user_secured_cols_temp] PRIMARY KEY CLUSTERED  ([security_id], [column_name], [report_security_id], [column_value]) ON [PRIMARY]
GO
