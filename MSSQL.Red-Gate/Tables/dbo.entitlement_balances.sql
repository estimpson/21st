CREATE TABLE [dbo].[entitlement_balances]
(
[entitle_year] [smallint] NOT NULL,
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[entitlement] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[hours_accrued] [decimal] (18, 6) NULL,
[hours_accrued_carryover] [decimal] (18, 6) NULL,
[hours_taken] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount_accrued] [decimal] (18, 6) NULL,
[amount_accrued_carryover] [decimal] (18, 6) NULL,
[amount_taken] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[entitlement_balances] ADD CONSTRAINT [pk_entitlement_balances] PRIMARY KEY CLUSTERED  ([entitle_year], [employee], [entitlement]) ON [PRIMARY]
GO
