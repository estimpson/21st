CREATE TABLE [dbo].[t4_definition_header]
(
[calendar_year] [smallint] NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t4_definition_header] ADD CONSTRAINT [pk_t4_definition_header] PRIMARY KEY CLUSTERED  ([calendar_year]) ON [PRIMARY]
GO
