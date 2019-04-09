CREATE TABLE [dbo].[positions]
(
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position_description] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grade] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eeoc_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[review_form_file] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eeoc_function] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[security_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_primary_function] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_academic_rank] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position_category] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position_family] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fringe_benefit_percent] [decimal] (12, 6) NULL,
[fringe_benefit_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[application] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position_description_document] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position_description_file_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position_pending] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reports_to_position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fringe_benefit_amount] [decimal] (12, 6) NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_soc_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_soc_subcategory] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[include_position_budget_init] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[review_form] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_occupational_category] [char] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[positions] ADD CONSTRAINT [pk_positions] PRIMARY KEY CLUSTERED  ([position]) ON [PRIMARY]
GO
