CREATE TABLE [dbo].[bank_rec_deposit_detail]
(
[security_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[statement_date] [datetime] NOT NULL,
[document_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_number] [int] NOT NULL,
[check_void_nsf] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_id2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_id3] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_date] [datetime] NULL,
[document_amount] [decimal] (18, 6) NULL,
[reconciled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reconciled_date] [datetime] NULL,
[reconciled_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_group_id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_group_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_account_debit_credit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_reference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_remarks] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_reference2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_document_group_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_document_group_date] [datetime] NULL,
[reconciled_amount] [decimal] (18, 6) NULL,
[cmc_document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[bank_rec_deposit_detail] ADD CONSTRAINT [pk_bank_rec_deposit_detail] PRIMARY KEY NONCLUSTERED  ([security_id], [bank_alias], [statement_date], [document_class], [document_number], [check_void_nsf]) ON [PRIMARY]
GO
