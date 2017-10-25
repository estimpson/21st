CREATE TABLE [dbo].[bank_register_items]
(
[bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_number] [int] NOT NULL,
[check_void_nsf] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_line] [smallint] NOT NULL,
[sort_line] [numeric] (8, 2) NULL,
[unit_of_measure] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [numeric] (18, 6) NULL,
[document_amount] [decimal] (18, 6) NULL,
[document_reference1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_reference2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_remarks] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_cost] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[bank_register_items] ADD CONSTRAINT [pk_bank_register_items] PRIMARY KEY CLUSTERED  ([bank_alias], [document_class], [document_number], [check_void_nsf], [document_line]) ON [PRIMARY]
GO
