CREATE TABLE [FT].[NumberSequenceKeys]
(
[KeyName] [sys].[sysname] NOT NULL,
[NumberSequenceID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [FT].[NumberSequenceKeys] ADD CONSTRAINT [PK__NumberSequenceKe__2A01FDF2] PRIMARY KEY CLUSTERED  ([KeyName]) ON [PRIMARY]
GO
ALTER TABLE [FT].[NumberSequenceKeys] ADD CONSTRAINT [FK__NumberSeq__Numbe__2AF6222B] FOREIGN KEY ([NumberSequenceID]) REFERENCES [FT].[NumberSequence] ([NumberSequenceID])
GO
