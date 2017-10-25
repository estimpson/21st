CREATE TABLE [FT].[StatusDefn]
(
[StatusID] [int] NOT NULL IDENTITY(1, 1),
[StatusTable] [sys].[sysname] NOT NULL,
[StatusCode] [int] NOT NULL,
[StatusName] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HelpText] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__StatusDef__LastU__1CA802D4] DEFAULT (suser_sname()),
[LastDT] [datetime] NULL CONSTRAINT [DF__StatusDef__LastD__1D9C270D] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [FT].[StatusDefn] ADD CONSTRAINT [PK__StatusDefn__1ABFBA62] PRIMARY KEY CLUSTERED  ([StatusID]) ON [PRIMARY]
GO
ALTER TABLE [FT].[StatusDefn] ADD CONSTRAINT [UQ__StatusDefn__1BB3DE9B] UNIQUE NONCLUSTERED  ([StatusTable], [StatusCode]) ON [PRIMARY]
GO
