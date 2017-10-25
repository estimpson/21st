CREATE TABLE [dbo].[entitlement_los]
(
[entitlement] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[service_years] [smallint] NOT NULL,
[service_months] [smallint] NOT NULL,
[service_days] [smallint] NOT NULL,
[max_accrue_hours] [decimal] (18, 6) NULL,
[max_balance_hours] [decimal] (18, 6) NULL,
[hours_to_accrue_annually] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[percent_to_accrue] [decimal] (12, 6) NULL,
[max_balance_dollars] [decimal] (18, 6) NULL,
[max_carryover_hours] [decimal] (18, 6) NULL,
[max_payout_hours] [decimal] (18, 6) NULL,
[max_payout_dollars] [decimal] (18, 6) NULL,
[max_accrue_dollars] [decimal] (18, 6) NULL,
[max_carryover_dollars] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[entitlement_los] ADD CONSTRAINT [pk_entitlement_los] PRIMARY KEY CLUSTERED  ([entitlement], [service_years], [service_months], [service_days]) ON [PRIMARY]
GO
