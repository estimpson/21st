CREATE TABLE [dbo].[position_budgets]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization_level] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position_budget_line] [smallint] NOT NULL,
[sort_line] [smallint] NULL,
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[annual_salary] [decimal] (18, 6) NULL,
[position_fte] [decimal] (18, 6) NULL,
[number_of_months] [smallint] NULL,
[budget_salary] [decimal] (18, 6) NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position_requisition] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[budget_note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fiscal_year_ledger] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position_budget_id] [int] NOT NULL IDENTITY(1, 1),
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[budget_fringe_benefits] [decimal] (18, 6) NULL,
[balance_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_cost_identity] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[position_budgets] ADD CONSTRAINT [pk_position_budgets] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [organization_level], [organization], [balance_name], [position_budget_line]) ON [PRIMARY]
GO
