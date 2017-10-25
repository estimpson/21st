CREATE TABLE [dbo].[ap_document_classes]
(
[document_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_class_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ap_document_classes] ADD CONSTRAINT [pk_ap_document_classes] PRIMARY KEY CLUSTERED  ([document_class]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
