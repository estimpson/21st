CREATE TABLE [dbo].[position_requisitions]
(
[position_requisition] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position_budget_id] [int] NULL,
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization_level] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_opened] [datetime] NULL,
[date_closed] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position_requisition_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expected_start_date] [datetime] NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[application] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recruiter] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[position_requisitions] ADD CONSTRAINT [pk_position_requisitions] PRIMARY KEY CLUSTERED  ([position_requisition]) ON [PRIMARY]
GO
