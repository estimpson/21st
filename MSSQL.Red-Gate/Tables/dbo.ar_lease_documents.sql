CREATE TABLE [dbo].[ar_lease_documents]
(
[lease] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lease_document_identity] [int] NOT NULL IDENTITY(1, 1),
[lease_document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_start_date] [datetime] NULL,
[document_expire_date] [datetime] NULL,
[document_notify_date] [datetime] NULL,
[document_reference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_remarks] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[lease_document_status] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ar_lease_documents] ADD CONSTRAINT [pk_ar_lease_documents] PRIMARY KEY CLUSTERED  ([lease], [lease_document_identity]) ON [PRIMARY]
GO
