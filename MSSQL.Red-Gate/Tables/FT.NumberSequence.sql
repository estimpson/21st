CREATE TABLE [FT].[NumberSequence]
(
[NumberSequenceID] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HelpText] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumberMask] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NextValue] [bigint] NOT NULL CONSTRAINT [DF__NumberSeq__NextV__26316D0E] DEFAULT ((1)),
[LastUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__NumberSeq__LastU__27259147] DEFAULT (suser_sname()),
[LastDT] [datetime] NULL CONSTRAINT [DF__NumberSeq__LastD__2819B580] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [FT].[NumberSequence] ADD CONSTRAINT [PK__NumberSequence__2449249C] PRIMARY KEY CLUSTERED  ([NumberSequenceID]) ON [PRIMARY]
GO
ALTER TABLE [FT].[NumberSequence] ADD CONSTRAINT [UQ__NumberSequence__253D48D5] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
