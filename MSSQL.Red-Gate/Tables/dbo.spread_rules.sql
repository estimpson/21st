CREATE TABLE [dbo].[spread_rules]
(
[spread_rule] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[period] [smallint] NOT NULL,
[rule_percent] [decimal] (12, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[spread_rules] ADD CONSTRAINT [pk_spread_rules] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [spread_rule], [period]) ON [PRIMARY]
GO
