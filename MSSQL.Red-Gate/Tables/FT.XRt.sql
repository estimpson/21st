CREATE TABLE [FT].[XRt]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[TopPart] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChildPart] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BOMID] [int] NULL,
[Sequence] [smallint] NULL,
[BOMLevel] [smallint] NOT NULL CONSTRAINT [DF__XRt__BOMLevel__7287ABD6] DEFAULT ((0)),
[XQty] [float] NULL CONSTRAINT [DF__XRt__XQty__737BD00F] DEFAULT ((1)),
[XScrap] [float] NULL CONSTRAINT [DF__XRt__XScrap__746FF448] DEFAULT ((1)),
[XBufferTime] [float] NOT NULL CONSTRAINT [DF__XRt__XBufferTime__75641881] DEFAULT ((0)),
[XRunRate] [float] NOT NULL CONSTRAINT [DF__XRt__XRunRate__76583CBA] DEFAULT ((0)),
[Hierarchy] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Infinite] [smallint] NOT NULL CONSTRAINT [DF__XRt__Infinite__774C60F3] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [FT].[XRt] ADD CONSTRAINT [PK__XRt__709F6364] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_XRt_1] ON [FT].[XRt] ([BOMLevel], [ChildPart], [ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [XRt_2] ON [FT].[XRt] ([ChildPart], [BOMLevel]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_XRt_3] ON [FT].[XRt] ([ChildPart], [BOMLevel], [ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_XRt_4] ON [FT].[XRt] ([ChildPart], [TopPart], [ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [XRt_1] ON [FT].[XRt] ([TopPart], [ChildPart], [Sequence], [XQty], [XScrap], [XBufferTime], [ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_XRt_5] ON [FT].[XRt] ([TopPart], [ChildPart], [XQty], [ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_XRt_2] ON [FT].[XRt] ([TopPart], [Hierarchy], [ID]) ON [PRIMARY]
GO
ALTER TABLE [FT].[XRt] ADD CONSTRAINT [UQ__XRt__7193879D] UNIQUE NONCLUSTERED  ([TopPart], [Sequence]) ON [PRIMARY]
GO
