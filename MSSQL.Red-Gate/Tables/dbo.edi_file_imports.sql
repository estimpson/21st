CREATE TABLE [dbo].[edi_file_imports]
(
[edi_file_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[edi_received_datetime] [datetime] NOT NULL,
[edi_document_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_control_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_file_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_error_file] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_completed_datetime] [datetime] NULL,
[empower_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_error_message] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_file_imports] ADD CONSTRAINT [pk_edi_file_imports] PRIMARY KEY CLUSTERED  ([edi_file_name]) ON [PRIMARY]
GO
