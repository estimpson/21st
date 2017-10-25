CREATE TABLE [dbo].[allocations]
(
[allocation] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[allocations] ADD CONSTRAINT [pk_allocations] PRIMARY KEY CLUSTERED  ([allocation], [fiscal_year], [ledger]) ON [PRIMARY]
GO
