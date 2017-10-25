CREATE TABLE [dbo].[ObjectHistory]
(
[SnapshotName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SnapshotDate] [datetime] NULL,
[SnapshotShift] [int] NULL,
[Serial] [int] NOT NULL,
[Part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Quantity] [numeric] (20, 6) NULL,
[StdQuantity] [numeric] (20, 6) NULL,
[Unit] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackageType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Note] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__ObjectHis__RowCr__298DC7FD] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ObjectHis__RowCr__2A81EC36] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__ObjectHis__RowMo__2B76106F] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ObjectHis__RowMo__2C6A34A8] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ObjectHistory] ADD CONSTRAINT [PK__ObjectHistory__27A57F8B] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ObjectHistory] ADD CONSTRAINT [UQ__ObjectHistory__2899A3C4] UNIQUE NONCLUSTERED  ([SnapshotName], [Serial]) ON [PRIMARY]
GO
