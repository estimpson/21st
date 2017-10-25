CREATE TABLE [FT].[CycleCountRFLogging]
(
[ProcName] [sys].[sysname] NOT NULL CONSTRAINT [DF__CycleCoun__ProcN__35BE94B8] DEFAULT (object_name(@@procid)),
[ActionTaken] [int] NOT NULL,
[ActionTakenMessage] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDT] [datetime] NULL CONSTRAINT [DF__CycleCoun__Start__36B2B8F1] DEFAULT (getdate()),
[EndDT] [datetime] NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__CycleCoun__RowCr__37A6DD2A] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__CycleCoun__RowCr__389B0163] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__CycleCoun__RowMo__398F259C] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__CycleCoun__RowMo__3A8349D5] DEFAULT (suser_name())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [FT].[CycleCountRFLogging] ADD CONSTRAINT [PK__CycleCountRFLogg__34CA707F] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
