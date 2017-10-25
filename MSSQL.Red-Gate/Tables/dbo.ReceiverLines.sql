CREATE TABLE [dbo].[ReceiverLines]
(
[ReceiverLineID] [int] NOT NULL IDENTITY(1, 1),
[ReceiverID] [int] NOT NULL,
[LineNo] [float] NOT NULL CONSTRAINT [DF__ReceiverL__LineN__3D14D266] DEFAULT ((0)),
[Status] [bigint] NOT NULL CONSTRAINT [DF__ReceiverL__Statu__3E08F69F] DEFAULT ((0)),
[PartCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PONumber] [int] NOT NULL,
[POLineNo] [int] NULL,
[POLineDueDate] [datetime] NULL,
[PackageType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RemainingBoxes] [int] NULL,
[StdPackQty] [numeric] (20, 6) NOT NULL,
[SupplierLotNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArrivalDT] [datetime] NULL,
[ReceiptDT] [datetime] NULL,
[PutawayDT] [datetime] NULL,
[LastUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ReceiverL__LastU__3EFD1AD8] DEFAULT (suser_sname()),
[LastDT] [datetime] NULL CONSTRAINT [DF__ReceiverL__LastD__3FF13F11] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReceiverLines] ADD CONSTRAINT [PK__ReceiverLines__3A3865BB] PRIMARY KEY CLUSTERED  ([ReceiverLineID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReceiverLines] ADD CONSTRAINT [UQ__ReceiverLines__3B2C89F4] UNIQUE NONCLUSTERED  ([ReceiverID], [LineNo]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReceiverLines] ADD CONSTRAINT [FK__ReceiverL__Recei__3C20AE2D] FOREIGN KEY ([ReceiverID]) REFERENCES [dbo].[ReceiverHeaders] ([ReceiverID])
GO
