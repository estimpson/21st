CREATE TABLE [dbo].[item_production]
(
[item_production_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_date] [datetime] NULL,
[gl_entry] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fiscal_year] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period] [smallint] NULL,
[quantity] [decimal] (18, 6) NULL,
[unit_cost] [decimal] (18, 6) NULL,
[amount] [decimal] (18, 6) NULL,
[debit_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[credit_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inventory_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inventory_uom_to_standard] [decimal] (18, 6) NULL,
[serial_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serial_uom_to_standard] [decimal] (18, 6) NULL,
[note] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[item_production] ADD CONSTRAINT [pk_item_production] PRIMARY KEY NONCLUSTERED  ([item_production_id]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [item_production_batch] ON [dbo].[item_production] ([batch]) ON [PRIMARY]
GO
