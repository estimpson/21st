CREATE TABLE [dbo].[employee_deduction_type_changes]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[employee_deduction_type_line] [int] NOT NULL,
[employee_deduction_type_change] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[canceled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[direct_deposit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dd_account_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transit_routing_no] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_submitted] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_deduction_type_changes] ADD CONSTRAINT [pk_employee_deduction_type_changes] PRIMARY KEY CLUSTERED  ([employee], [employee_deduction_type_line], [employee_deduction_type_change]) ON [PRIMARY]
GO
