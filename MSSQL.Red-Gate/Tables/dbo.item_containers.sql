CREATE TABLE [dbo].[item_containers]
(
[container_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[container] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[container_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[container_gross_weight] [decimal] (18, 6) NULL,
[container_net_weight] [decimal] (18, 6) NULL,
[container_weight_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[container_gross_weight_kgs] [decimal] (18, 6) NULL,
[container_net_weight_kgs] [decimal] (18, 6) NULL,
[container_width] [decimal] (18, 6) NULL,
[container_length] [decimal] (18, 6) NULL,
[container_height] [decimal] (18, 6) NULL,
[container_dimensions_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_of_lading] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[item_containers] ADD CONSTRAINT [pk_item_containers] PRIMARY KEY CLUSTERED  ([container_id]) ON [PRIMARY]
GO
