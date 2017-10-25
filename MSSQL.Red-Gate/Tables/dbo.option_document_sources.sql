CREATE TABLE [dbo].[option_document_sources]
(
[option_id] [uniqueidentifier] NOT NULL,
[document_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[option_document_sources] ADD CONSTRAINT [pk_option_document_sources] PRIMARY KEY CLUSTERED  ([option_id], [document_source]) ON [PRIMARY]
GO
