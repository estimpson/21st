CREATE TABLE [dbo].[payroll_cycles]
(
[payroll_cycle] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cycle_begin_date] [datetime] NULL,
[cycle_end_date] [datetime] NULL,
[check_date] [datetime] NULL,
[pay_types_calc_sels] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deduction_types_calc_sels] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[benefit_types_calc_sels] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_date_1] [datetime] NULL,
[gl_period_1_percent] [decimal] (18, 6) NULL,
[gl_date_2] [datetime] NULL,
[gl_period_2_percent] [decimal] (18, 6) NULL,
[period_end_date] [datetime] NULL,
[retirement_types_calc_sels] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payroll_calculation_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[calculation_status] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fiscal_year_1] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fiscal_year_2] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_gl_date] [datetime] NULL,
[check_fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[override_direct_deposit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entitlements_calc_sels] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entitle_year] [smallint] NULL,
[check_message] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suppress_message_emp_ids] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[print_in_progress] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[history_import_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[close_timecard_entry] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[payroll_cycles] ADD CONSTRAINT [pk_payroll_cycles] PRIMARY KEY CLUSTERED  ([payroll_cycle]) ON [PRIMARY]
GO
