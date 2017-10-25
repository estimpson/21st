CREATE TABLE [FT].[TypeDefn]
(
[TypeID] [int] NOT NULL IDENTITY(1, 1),
[TypeTable] [sys].[sysname] NOT NULL,
[TypeCode] [int] NOT NULL,
[TypeName] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HelpText] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__TypeDefn__LastUs__216CB7F1] DEFAULT (suser_sname()),
[LastDT] [datetime] NULL CONSTRAINT [DF__TypeDefn__LastDT__2260DC2A] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [FT].[TypeDefn] ADD CONSTRAINT [PK__TypeDefn__1F846F7F] PRIMARY KEY CLUSTERED  ([TypeID]) ON [PRIMARY]
GO
ALTER TABLE [FT].[TypeDefn] ADD CONSTRAINT [UQ__TypeDefn__207893B8] UNIQUE NONCLUSTERED  ([TypeTable], [TypeCode]) ON [PRIMARY]
GO
