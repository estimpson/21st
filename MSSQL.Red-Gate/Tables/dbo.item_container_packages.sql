CREATE TABLE [dbo].[item_container_packages]
(
[container_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[package] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[package_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_gross_weight] [decimal] (18, 6) NULL,
[package_net_weight] [decimal] (18, 6) NULL,
[package_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_weight_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_width] [decimal] (18, 6) NULL,
[package_length] [decimal] (18, 6) NULL,
[package_height] [decimal] (18, 6) NULL,
[package_dimensions_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_gross_weight_kgs] [decimal] (18, 6) NULL,
[package_net_weight_kgs] [decimal] (18, 6) NULL,
[purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_of_lading] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[item_container_packages] ADD CONSTRAINT [pk_item_container_packages] PRIMARY KEY CLUSTERED  ([container_id], [package]) ON [PRIMARY]
GO
