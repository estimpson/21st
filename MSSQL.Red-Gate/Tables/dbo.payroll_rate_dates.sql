CREATE TABLE [dbo].[payroll_rate_dates]
(
[rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[begin_date] [datetime] NOT NULL,
[end_date] [datetime] NOT NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[import_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contract_amount] [decimal] (18, 6) NULL,
[number_of_payments] [int] NULL,
[contract_annual_amount] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[payroll_rate_dates] ADD CONSTRAINT [pk_payroll_rate_dates] PRIMARY KEY CLUSTERED  ([rate_id], [begin_date]) ON [PRIMARY]
GO
