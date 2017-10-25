CREATE TABLE [dbo].[ReceiverObjects]
(
[ReceiverObjectID] [int] NOT NULL IDENTITY(1, 1),
[ReceiverLineID] [int] NOT NULL,
[LineNo] [float] NOT NULL CONSTRAINT [DF__ReceiverO__LineN__19968BFF] DEFAULT ((0)),
[Status] [bigint] NOT NULL CONSTRAINT [DF__ReceiverO__Statu__1A8AB038] DEFAULT ((0)),
[PONumber] [int] NOT NULL,
[POLineNo] [int] NULL,
[POLineDueDate] [datetime] NULL,
[Serial] [int] NULL,
[PartCode] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PartDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EngineeringLevel] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyObject] [numeric] (20, 6) NOT NULL,
[PackageType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Plant] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentSerial] [int] NULL,
[DrAccount] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CrAccount] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lot] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Note] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefinedStatus] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceiveDT] [datetime] NULL,
[LastUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ReceiverO__LastU__1B7ED471] DEFAULT (suser_sname()),
[LastDT] [datetime] NULL CONSTRAINT [DF__ReceiverO__LastD__1C72F8AA] DEFAULT (getdate()),
[ParentLicensePlate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplierLicensePlate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReceiverObjects] ADD CONSTRAINT [PK__ReceiverObjects__16BA1F54] PRIMARY KEY CLUSTERED  ([ReceiverObjectID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReceiverObjects] ADD CONSTRAINT [UQ__ReceiverObjects__17AE438D] UNIQUE NONCLUSTERED  ([ReceiverLineID], [LineNo]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReceiverObjects] ADD CONSTRAINT [FK__ReceiverO__Recei__18A267C6] FOREIGN KEY ([ReceiverLineID]) REFERENCES [dbo].[ReceiverLines] ([ReceiverLineID])
GO
