CREATE TABLE [dbo].[retirement_plan_groups]
(
[retirement_plan_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[retirement_plan_group_desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employer_match_max_percent] [decimal] (18, 6) NULL,
[employer_match_multiplier] [decimal] (18, 6) NULL,
[employee_contribution_limit] [decimal] (18, 6) NULL,
[employee_basis_limit] [decimal] (18, 6) NULL,
[employee_max_percent] [decimal] (18, 6) NULL,
[employer_match_max_amount] [decimal] (18, 6) NULL,
[employer_match_basis_limit] [decimal] (18, 6) NULL,
[employer_basis_limit] [decimal] (18, 6) NULL,
[employer_max_percent] [decimal] (18, 6) NULL,
[employer_contribution_limit] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[security_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employer_match_method] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[retirement_plan_groups] ADD CONSTRAINT [pk_retirement_plan_groups] PRIMARY KEY CLUSTERED  ([retirement_plan_group]) ON [PRIMARY]
GO
