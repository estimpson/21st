CREATE TABLE [dbo].[calculation_adjustments]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[payroll_date] [datetime] NOT NULL,
[entry_datetime] [datetime] NOT NULL,
[payroll_cycle] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adjustment_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adjustment_document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payroll_calculation_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_sequence] [smallint] NULL,
[voucher] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_void] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adjustment_identity] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[calculation_adjustments] ADD CONSTRAINT [pk_calculation_adjustments] PRIMARY KEY CLUSTERED  ([employee], [payroll_date], [entry_datetime], [adjustment_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [calc_adj_cycle_employee] ON [dbo].[calculation_adjustments] ([payroll_cycle], [employee], [voucher]) ON [PRIMARY]
GO
