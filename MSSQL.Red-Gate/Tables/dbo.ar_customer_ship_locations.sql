CREATE TABLE [dbo].[ar_customer_ship_locations]
(
[customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ship_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ship_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_contact_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primary_ship_location] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[label_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[writeoff_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[overpay_sales_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[destination_label_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ar_customer_ship_locations] ADD CONSTRAINT [pk_ar_customer_ship_locations] PRIMARY KEY NONCLUSTERED  ([customer], [ship_location]) ON [PRIMARY]
GO
