CREATE TABLE [dbo].[expenses_items]
(
[expense_report] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[expense_line] [smallint] NOT NULL,
[sort_line] [decimal] (8, 2) NULL,
[activity_date] [datetime] NULL,
[expense_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expense_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expense_amount] [decimal] (18, 6) NULL,
[reimbursed_amount] [decimal] (18, 6) NULL,
[receipt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[charge_card_memo] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expense_analysis] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purpose] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[expenses_items] ADD CONSTRAINT [pk_expenses_items] PRIMARY KEY CLUSTERED  ([expense_report], [expense_line]) ON [PRIMARY]
GO
