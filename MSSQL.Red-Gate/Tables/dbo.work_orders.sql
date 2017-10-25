CREATE TABLE [dbo].[work_orders]
(
[work_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[work_order_date] [datetime] NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inventory_quantity] [decimal] (18, 6) NULL,
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[team_leader] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shift_worked] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[work_orders] ADD CONSTRAINT [pk_work_orders] PRIMARY KEY CLUSTERED  ([work_order]) ON [PRIMARY]
GO
