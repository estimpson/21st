CREATE TABLE [dbo].[WIPSheetFromBobbi]
(
[Part] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UnitPric] [numeric] (12, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WIPSheetFromBobbi] ADD CONSTRAINT [PK_WIPSheetFromBobbi] PRIMARY KEY CLUSTERED  ([Part]) ON [PRIMARY]
GO
