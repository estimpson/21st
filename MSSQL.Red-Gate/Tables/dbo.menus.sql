CREATE TABLE [dbo].[menus]
(
[menu_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[parent_menu_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sort_line] [numeric] (18, 6) NULL,
[menu_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[option_id] [uniqueidentifier] NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[menus] ADD CONSTRAINT [pk_menus] PRIMARY KEY CLUSTERED  ([menu_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[menus] ADD CONSTRAINT [FK_menus_options] FOREIGN KEY ([option_id]) REFERENCES [dbo].[options] ([option_id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
