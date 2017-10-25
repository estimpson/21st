CREATE TABLE [dbo].[BlanketPriceAdmin]
(
[TableName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AllowUpdate] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BlanketPriceAdmin] ADD CONSTRAINT [PK__BlanketPriceAdmi__74EF1735] PRIMARY KEY CLUSTERED  ([TableName]) ON [PRIMARY]
GO
