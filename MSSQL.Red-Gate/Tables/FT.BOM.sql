CREATE TABLE [FT].[BOM]
(
[BOMID] [int] NOT NULL,
[ParentPart] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChildPart] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StdQty] [numeric] (20, 6) NULL,
[ScrapFactor] [numeric] (20, 6) NULL,
[SubstitutePart] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [FT].[BOM] ADD CONSTRAINT [PK__BOM__16500B00] PRIMARY KEY CLUSTERED  ([BOMID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [BOM_1] ON [FT].[BOM] ([ChildPart], [ParentPart]) ON [PRIMARY]
GO
ALTER TABLE [FT].[BOM] ADD CONSTRAINT [UQ__BOM__17442F39] UNIQUE NONCLUSTERED  ([ParentPart], [ChildPart]) ON [PRIMARY]
GO
