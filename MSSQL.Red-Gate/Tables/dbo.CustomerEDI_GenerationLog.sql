CREATE TABLE [dbo].[CustomerEDI_GenerationLog]
(
[FileStreamID] [uniqueidentifier] NOT NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__CustomerE__Statu__683D56B7] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__CustomerED__Type__69317AF0] DEFAULT ((0)),
[ShipperID] [int] NULL,
[FileGenerationDT] [datetime] NOT NULL,
[FileSendDT] [datetime] NULL,
[FileAcknowledgementDT] [datetime] NULL,
[OriginalFileName] [sys].[sysname] NULL,
[CurrentFilePath] [sys].[sysname] NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__CustomerE__RowCr__6A259F29] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__CustomerE__RowCr__6B19C362] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__CustomerE__RowMo__6C0DE79B] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__CustomerE__RowMo__6D020BD4] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerEDI_GenerationLog] ADD CONSTRAINT [PK__Customer__FFEE74516378A19A] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerEDI_GenerationLog] ADD CONSTRAINT [UQ__Customer__2957490C66550E45] UNIQUE NONCLUSTERED  ([FileStreamID]) ON [PRIMARY]
GO
