CREATE TABLE [dbo].[InventoryControl_CycleCountObjectsCopy]
(
[CycleCountNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Line] [float] NULL,
[Serial] [int] NULL,
[Status] [int] NOT NULL,
[Type] [int] NOT NULL,
[Part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OriginalQuantity] [numeric] (20, 6) NOT NULL,
[CorrectedQuantity] [numeric] (20, 6) NULL,
[Unit] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OriginalLocation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CorrectedLocation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL,
[RowCreateUser] [sys].[sysname] NOT NULL,
[RowModifiedDT] [datetime] NULL,
[RowModifiedUser] [sys].[sysname] NOT NULL
) ON [PRIMARY]
GO
