CREATE TABLE [dbo].[bank_register_published]
(
[bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_number] [int] NOT NULL,
[check_void_nsf] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[file_id] [uniqueidentifier] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bank_register_published] ADD CONSTRAINT [pk_bank_register_published] PRIMARY KEY CLUSTERED  ([bank_alias], [document_class], [document_number], [check_void_nsf]) ON [PRIMARY]
GO
