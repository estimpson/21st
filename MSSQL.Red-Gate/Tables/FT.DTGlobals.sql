CREATE TABLE [FT].[DTGlobals]
(
[Name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [FT].[DTGlobals] ADD CONSTRAINT [PK__DTGlobals__192C77AB] PRIMARY KEY CLUSTERED  ([Name]) ON [PRIMARY]
GO
