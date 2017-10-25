CREATE TABLE [dbo].[ledger_periods]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[period] [smallint] NOT NULL,
[ap_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ar_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ba_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[co_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fa_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iv_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[py_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[so_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cv_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ledger_periods] ADD CONSTRAINT [pk_ledger_periods] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [period]) ON [PRIMARY]
GO
