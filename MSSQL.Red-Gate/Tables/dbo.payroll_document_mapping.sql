CREATE TABLE [dbo].[payroll_document_mapping]
(
[import_value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[payroll_document_mapping] ADD CONSTRAINT [pk_payroll_document_mapping] PRIMARY KEY CLUSTERED  ([import_value]) ON [PRIMARY]
GO
