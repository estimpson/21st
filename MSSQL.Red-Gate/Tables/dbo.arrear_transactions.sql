CREATE TABLE [dbo].[arrear_transactions]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[arrear_line] [int] NOT NULL,
[payroll_calculation_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount] [decimal] (18, 6) NULL,
[transaction_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transaction_date] [datetime] NULL,
[transaction_reference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[arrear_transactions] ADD CONSTRAINT [pk_arrear_transactions] PRIMARY KEY CLUSTERED  ([employee], [document], [document_type], [arrear_line]) ON [PRIMARY]
GO
