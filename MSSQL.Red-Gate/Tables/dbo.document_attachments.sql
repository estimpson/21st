CREATE TABLE [dbo].[document_attachments]
(
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[attachment_id] [int] NOT NULL IDENTITY(1, 1),
[attachment_description] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[file_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[document_attachments] ADD CONSTRAINT [pk_document_attachments] PRIMARY KEY CLUSTERED  ([document_type], [document_id1], [document_id2], [document_id3], [attachment_id]) ON [PRIMARY]
GO
