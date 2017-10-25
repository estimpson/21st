CREATE TABLE [dbo].[PartImport]
(
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartImport] ADD CONSTRAINT [PK_PartImport] PRIMARY KEY CLUSTERED  ([part]) ON [PRIMARY]
GO
