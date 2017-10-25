CREATE TABLE [FT].[MenuItems]
(
[MenuID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__MenuItems__MenuI__361DBC14] DEFAULT (newid()),
[MenuItemName] [sys].[sysname] NOT NULL,
[ItemOwner] [sys].[sysname] NOT NULL,
[Status] [int] NULL,
[Type] [int] NULL,
[MenuText] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MenuIcon] [sys].[sysname] NOT NULL,
[ObjectClass] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [FT].[MenuItems] ADD CONSTRAINT [PK__MenuItems__352997DB] PRIMARY KEY NONCLUSTERED  ([MenuID]) ON [PRIMARY]
GO
ALTER TABLE [FT].[MenuItems] ADD CONSTRAINT [UQ__MenuItems__343573A2] UNIQUE NONCLUSTERED  ([MenuItemName], [ItemOwner]) ON [PRIMARY]
GO
