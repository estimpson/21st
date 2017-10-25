CREATE TABLE [dbo].[monitor_inventory_accounts]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[product_line] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[audit_trail_type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[part_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sort_line] [int] NULL,
[empower_interface] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[material_debit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[material_credit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[material_variance] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[labor_debit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[labor_credit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[burden_debit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[burden_credit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[other_debit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[other_credit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[monitor_inventory_accounts] ADD CONSTRAINT [pk_monitor_inv_accounts] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [product_line], [audit_trail_type], [part_type]) ON [PRIMARY]
GO
