CREATE TABLE [dbo].[position_budget_notes]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization_level] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[organization] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[balance_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position_budget_line] [smallint] NOT NULL,
[note_id] [int] NOT NULL IDENTITY(1, 1),
[note_date] [datetime] NOT NULL,
[note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[follow_up_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[position_budget_notes] ADD CONSTRAINT [pk_position_budget_notes] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [balance_name], [organization_level], [organization], [position_budget_line], [note_id]) ON [PRIMARY]
GO
