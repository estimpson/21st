CREATE TABLE [dbo].[ar_program_event_items]
(
[program] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[program_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[quantity] [numeric] (18, 6) NULL,
[ledger_account_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[sort_line] [smallint] NULL,
[cost_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[taxable_1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[taxable_2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freight] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ar_program_event_items] ADD CONSTRAINT [pk_ar_program_event_items] PRIMARY KEY CLUSTERED  ([program], [program_event], [item]) ON [PRIMARY]
GO
