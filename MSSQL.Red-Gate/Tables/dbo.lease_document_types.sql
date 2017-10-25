CREATE TABLE [dbo].[lease_document_types]
(
[lease_document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lease_document_type_desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lease_document_types] ADD CONSTRAINT [pk_lease_document_types] PRIMARY KEY CLUSTERED  ([lease_document_type]) ON [PRIMARY]
GO
