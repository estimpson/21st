CREATE TABLE [dbo].[ar_lease_items]
(
[lease] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lease_item_identity] [int] NOT NULL IDENTITY(1, 1),
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[item_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [numeric] (18, 6) NULL,
[item_price] [decimal] (18, 6) NULL,
[extended_amount] [decimal] (18, 6) NULL,
[selling_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sort_line] [smallint] NULL,
[cost_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[taxable_1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[taxable_2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[begin_date] [datetime] NULL,
[end_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[lease_space] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ar_lease_items] ADD CONSTRAINT [pk_ar_lease_items] PRIMARY KEY CLUSTERED  ([lease], [lease_item_identity]) ON [PRIMARY]
GO
