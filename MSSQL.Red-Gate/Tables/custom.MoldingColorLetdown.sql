CREATE TABLE [custom].[MoldingColorLetdown]
(
[MoldApplication] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BaseMaterialCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColorCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColorName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColorantCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LetDownRate] [numeric] (4, 2) NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__MoldingCo__Statu__2F90BA16] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__MoldingCol__Type__3084DE4F] DEFAULT ((0)),
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__MoldingCo__RowCr__31790288] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__MoldingCo__RowCr__326D26C1] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__MoldingCo__RowMo__33614AFA] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__MoldingCo__RowMo__34556F33] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [custom].[MoldingColorLetdown] ADD CONSTRAINT [PK__MoldingColorLetd__2DA871A4] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [custom].[MoldingColorLetdown] ADD CONSTRAINT [UQ__MoldingColorLetd__2E9C95DD] UNIQUE NONCLUSTERED  ([MoldApplication], [BaseMaterialCode], [ColorCode]) ON [PRIMARY]
GO
