CREATE TABLE [dbo].[approver_notes]
(
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id3] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[approver] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[note_date] [datetime] NOT NULL,
[approver_notes] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[approver_notes] ADD CONSTRAINT [pk_approver_notes] PRIMARY KEY CLUSTERED  ([document_type], [document_id1], [document_id2], [document_id3], [approver], [note_date]) ON [PRIMARY]
GO
