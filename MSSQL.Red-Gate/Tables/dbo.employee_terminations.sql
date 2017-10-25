CREATE TABLE [dbo].[employee_terminations]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[termination_date] [datetime] NOT NULL,
[interview_date] [datetime] NULL,
[interviewer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[termination_reason] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[termination_comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_employment_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[select_for_calc_thru_date] [datetime] NULL,
[pay_thru_date] [datetime] NULL,
[deductions_thru_date] [datetime] NULL,
[benefits_thru_date] [datetime] NULL,
[retirements_thru_date] [datetime] NULL,
[position_end_date] [datetime] NULL,
[equipment_return_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hire_date] [datetime] NULL,
[deceased_date] [datetime] NULL,
[new_employment_status] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employment_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_frequency] [int] NULL,
[recall_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expected_recall_date] [datetime] NULL,
[roe_last_date_paid] [datetime] NULL,
[term_or_leave] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[roe_created] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[roe_final_ppe_date] [datetime] NULL,
[reviews_deleted] [smallint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_terminations] ADD CONSTRAINT [pk_employee_terminations] PRIMARY KEY CLUSTERED  ([employee], [termination_date]) ON [PRIMARY]
GO
