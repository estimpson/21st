CREATE TABLE [dbo].[pay_types]
(
[pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pay_type_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_stub_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employee_pay_type_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entitlement] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[absence_tracking] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reduction_pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_id_scheme] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[security_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entitlement_accrued_taken] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entitlement_accrued_factor] [decimal] (18, 6) NULL,
[cr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paid] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[worked] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[banked] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ncr] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[base_pay] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[piece_pay] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[t4a] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[workstudy] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[time_of_day] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_periods_taxed] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pay_types] ADD CONSTRAINT [pk_pay_types] PRIMARY KEY CLUSTERED  ([pay_type]) ON [PRIMARY]
GO
