CREATE TABLE [dbo].[allocation_rules]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[allocation_rule] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[allocation_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allocation_sequence] [int] NOT NULL,
[je_reference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[je_reason] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[je_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reverse_next_period] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[allocate_from_org_level] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allocate_from_organization] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allocate_from_account] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allocate_from_period_ytd] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allocate_by_org_level] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allocate_by_organization] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allocate_by_account] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allocate_by_period_ytd] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allocate_to_org_level] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allocate_to_organization] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allocate_to_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[offset_to_org_level] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offset_to_organization] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offset_to_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[allocation_rules] ADD CONSTRAINT [pk_allocation_rules] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [allocation_rule]) ON [PRIMARY]
GO
