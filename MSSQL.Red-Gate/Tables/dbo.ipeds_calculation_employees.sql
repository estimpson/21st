CREATE TABLE [dbo].[ipeds_calculation_employees]
(
[ipeds_calculation] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[employee_division] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employee_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employment_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_academic_rank] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_annual_amount] [decimal] (18, 6) NULL,
[ipeds_full_time] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_race] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_occupational_category] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_tenure_status] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_months_worked] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hire_date] [datetime] NULL,
[termination_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ipeds_calculation_employees] ADD CONSTRAINT [pk_ipeds_calculation_employees] PRIMARY KEY CLUSTERED  ([ipeds_calculation], [employee]) ON [PRIMARY]
GO
