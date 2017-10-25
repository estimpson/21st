CREATE TABLE [dbo].[ar_document_classes]
(
[document_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_class_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ar_document_classes] ADD CONSTRAINT [pk_ar_document_classes] PRIMARY KEY CLUSTERED  ([document_class]) ON [PRIMARY]
GO
