CREATE TABLE [dbo].[FGSheetFromBobbi]
(
[Part] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UnitPric] [numeric] (12, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FGSheetFromBobbi] ADD CONSTRAINT [PK_FGSheetFromBobbi] PRIMARY KEY CLUSTERED  ([Part]) ON [PRIMARY]
GO
