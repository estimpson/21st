CREATE TABLE [dbo].[employee_ytd_balances]
(
[calendar_year] [smallint] NOT NULL,
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[hours] [decimal] (18, 6) NULL,
[amount] [decimal] (18, 6) NULL,
[basis_amount] [decimal] (18, 6) NULL,
[payer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[gross_amount] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours_worked] [decimal] (18, 6) NULL,
[pieces_paid] [decimal] (18, 6) NULL,
[amount_banked] [decimal] (18, 6) NULL,
[hours_banked] [decimal] (18, 6) NULL,
[basis_hours] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_ytd_balances] ADD CONSTRAINT [pk_employee_ytd_balances] PRIMARY KEY CLUSTERED  ([calendar_year], [employee], [document], [document_type], [payer]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [employee_ytd_ltd] ON [dbo].[employee_ytd_balances] ([employee], [document], [document_type], [payer]) ON [PRIMARY]
GO
