CREATE TABLE [dbo].[journal_entry_items]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_line] [smallint] NOT NULL,
[sort_line] [numeric] (8, 2) NULL,
[document_amount] [decimal] (18, 6) NULL,
[document_reference1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_reference2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_remarks] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [numeric] (18, 6) NULL,
[unit_of_measure] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_cost] [decimal] (18, 6) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[journal_entry_items] ADD CONSTRAINT [pk_journal_entry_items] PRIMARY KEY NONCLUSTERED  ([fiscal_year], [ledger], [gl_entry], [document_line]) ON [PRIMARY]
GO
