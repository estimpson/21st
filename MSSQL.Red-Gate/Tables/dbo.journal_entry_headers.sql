CREATE TABLE [dbo].[journal_entry_headers]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[period] [smallint] NULL,
[document_date] [datetime] NULL,
[currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_amount] [decimal] (18, 6) NULL,
[ledger_amount] [decimal] (18, 6) NULL,
[status] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[balance_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[je_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[related_gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
