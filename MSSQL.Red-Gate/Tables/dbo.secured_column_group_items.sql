CREATE TABLE [dbo].[secured_column_group_items]
(
[secured_column_group_id] [uniqueidentifier] NOT NULL,
[secured_column_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[valid_values] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[secured_column_group_items] ADD CONSTRAINT [pk_secured_column_group_items] PRIMARY KEY CLUSTERED  ([secured_column_group_id], [secured_column_name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[secured_column_group_items] ADD CONSTRAINT [FK_secured_column_group_items_secured_column_groups] FOREIGN KEY ([secured_column_group_id]) REFERENCES [dbo].[secured_column_groups] ([secured_column_group_id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[secured_column_group_items] ADD CONSTRAINT [FK_secured_column_group_items_secured_columns] FOREIGN KEY ([secured_column_name]) REFERENCES [dbo].[secured_columns] ([secured_column_name]) ON DELETE CASCADE ON UPDATE CASCADE
GO
