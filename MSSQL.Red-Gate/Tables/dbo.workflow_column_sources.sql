CREATE TABLE [dbo].[workflow_column_sources]
(
[workflow] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[column_source] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[column_label] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[workflow_column_sources] ADD CONSTRAINT [pk_workflow_column_sources] PRIMARY KEY CLUSTERED  ([workflow], [column_source]) ON [PRIMARY]
GO
