CREATE TABLE [dbo].[item_price_groups]
(
[item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[price_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[min_quantity] [decimal] (18, 6) NOT NULL,
[max_quantity] [decimal] (18, 6) NULL,
[price] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_agent_percent] [decimal] (18, 6) NULL,
[account_manager_percent] [decimal] (18, 6) NULL,
[customer_item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[item_price_groups] ADD CONSTRAINT [pk_item_price_groups] PRIMARY KEY CLUSTERED  ([item], [price_group], [min_quantity]) ON [PRIMARY]
GO
