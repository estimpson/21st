CREATE TABLE [dbo].[units_payroll_hr]
(
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_entry_frequency] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[accr_pay_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[time_card_approval_freq] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logo_file_id] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[units_payroll_hr] ADD CONSTRAINT [pk_units_payroll_hr] PRIMARY KEY CLUSTERED  ([unit]) ON [PRIMARY]
GO
