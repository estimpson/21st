CREATE TABLE [dbo].[CustomerEDI_GenerationLog_Responses]
(
[FileStreamID] [uniqueidentifier] NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__CustomerE__Statu__6C779C8A] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__CustomerED__Type__6D6BC0C3] DEFAULT ((0)),
[ParentFileStreamID] [uniqueidentifier] NULL,
[ParentGenerationLogRowID] [int] NULL,
[MessageInfo] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserNotes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__CustomerE__UserN__6E5FE4FC] DEFAULT (suser_name()),
[ExceptionHandler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__CustomerE__RowCr__6F540935] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__CustomerE__RowCr__70482D6E] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__CustomerE__RowMo__713C51A7] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__CustomerE__RowMo__723075E0] DEFAULT (suser_name())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerEDI_GenerationLog_Responses] ADD CONSTRAINT [PK__Customer__FFEE74517A032426] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerEDI_GenerationLog_Responses] ADD CONSTRAINT [UQ__Customer__2957490C15CBB4CE] UNIQUE NONCLUSTERED  ([FileStreamID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerEDI_GenerationLog_Responses] ADD CONSTRAINT [UQ__Customer__2957490CDB93E559] UNIQUE NONCLUSTERED  ([FileStreamID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerEDI_GenerationLog_Responses] ADD CONSTRAINT [FK__CustomerE__Paren__22109A79] FOREIGN KEY ([ParentFileStreamID]) REFERENCES [dbo].[CustomerEDI_GenerationLog] ([FileStreamID])
GO
ALTER TABLE [dbo].[CustomerEDI_GenerationLog_Responses] ADD CONSTRAINT [FK__CustomerE__Paren__2304BEB2] FOREIGN KEY ([ParentGenerationLogRowID]) REFERENCES [dbo].[CustomerEDI_GenerationLog] ([RowID])
GO
ALTER TABLE [dbo].[CustomerEDI_GenerationLog_Responses] ADD CONSTRAINT [FK__CustomerE__Paren__750CE28B] FOREIGN KEY ([ParentFileStreamID]) REFERENCES [dbo].[CustomerEDI_GenerationLog] ([FileStreamID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CustomerEDI_GenerationLog_Responses] ADD CONSTRAINT [FK__CustomerE__Paren__78DD736F] FOREIGN KEY ([ParentGenerationLogRowID]) REFERENCES [dbo].[CustomerEDI_GenerationLog] ([RowID])
GO
ALTER TABLE [dbo].[CustomerEDI_GenerationLog_Responses] ADD CONSTRAINT [FK__CustomerE__Paren__760106C4] FOREIGN KEY ([ParentGenerationLogRowID]) REFERENCES [dbo].[CustomerEDI_GenerationLog] ([RowID])
GO
