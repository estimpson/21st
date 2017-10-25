CREATE TABLE [dbo].[item_bill_of_material]
(
[item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[raw_material_item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[quantity] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[item_bill_of_material] ADD CONSTRAINT [pk_item_bill_of_material] PRIMARY KEY CLUSTERED  ([item], [raw_material_item]) ON [PRIMARY]
GO
