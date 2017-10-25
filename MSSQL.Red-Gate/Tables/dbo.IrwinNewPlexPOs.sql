CREATE TABLE [dbo].[IrwinNewPlexPOs]
(
[IrwinPart] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IrwinPO] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IrwinNewPlexPOs] ADD CONSTRAINT [PK_IrwinNewPlexPOs] PRIMARY KEY CLUSTERED  ([IrwinPart]) ON [PRIMARY]
GO
