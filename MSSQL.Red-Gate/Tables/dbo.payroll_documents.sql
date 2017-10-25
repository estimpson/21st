CREATE TABLE [dbo].[payroll_documents]
(
[document] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sort_order] [int] NOT NULL,
[summation_sign] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[payroll_documents] ADD CONSTRAINT [pk_payroll_documents] PRIMARY KEY CLUSTERED  ([document]) ON [PRIMARY]
GO
