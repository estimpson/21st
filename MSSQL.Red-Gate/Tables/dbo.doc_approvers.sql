CREATE TABLE [dbo].[doc_approvers]
(
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id3] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[approval_sequence] [smallint] NOT NULL,
[approver] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[breakpoint] [int] NULL,
[priority] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approved_by] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approved_date] [datetime] NULL,
[approved] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[next_to_approve] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approver_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[doc_approvers] ADD CONSTRAINT [pk_doc_approvers] PRIMARY KEY NONCLUSTERED  ([document_type], [document_id1], [document_id2], [document_id3], [approval_sequence]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [doc_approvers_approver] ON [dbo].[doc_approvers] ([approver], [approved]) ON [PRIMARY]
GO
