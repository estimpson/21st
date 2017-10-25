CREATE TABLE [dbo].[ReceiverHeaders]
(
[ReceiverID] [int] NOT NULL IDENTITY(1, 1),
[ReceiverNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [int] NOT NULL CONSTRAINT [DF__ReceiverHe__Type__2FBAD748] DEFAULT ((1)),
[Status] [int] NOT NULL CONSTRAINT [DF__ReceiverH__Statu__30AEFB81] DEFAULT ((0)),
[ShipFrom] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Plant] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExpectedReceiveDT] [datetime] NULL,
[ConfirmedShipDT] [datetime] NULL,
[ConfirmedSID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConfirmedArrivalDT] [datetime] NULL,
[TrackingNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActualArrivalDT] [datetime] NULL,
[ReceiveDT] [datetime] NULL,
[PutawayDT] [datetime] NULL,
[Note] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ReceiverH__LastU__31A31FBA] DEFAULT (suser_sname()),
[LastDT] [datetime] NULL CONSTRAINT [DF__ReceiverH__LastD__329743F3] DEFAULT (getdate()),
[SupplierASNGuid] [uniqueidentifier] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[trReceiverHeaders] on [dbo].[ReceiverHeaders] for insert
as
declare	@Value bigint,
	@NumberMask varchar(50)

select	@Value = FT.NumberSequence.NextValue,
	@NumberMask = FT.NumberSequence.NumberMask
from	FT.NumberSequence with (UPDLOCK)
	join FT.NumberSequenceKeys on FT.NumberSequence.NumberSequenceID = FT.NumberSequenceKeys.NumberSequenceID
where	FT.NumberSequenceKeys.KeyName = 'dbo.ReceiverHeaders.ReceiverID'

update	FT.NumberSequence
set	NextValue = NextValue + 1
from	FT.NumberSequence
	join FT.NumberSequenceKeys on FT.NumberSequence.NumberSequenceID = FT.NumberSequenceKeys.NumberSequenceID
where	FT.NumberSequenceKeys.KeyName = 'dbo.ReceiverHeaders.ReceiverID'

update	ReceiverHeaders
set	ReceiverNumber = convert (varchar(50), @Value)
from	ReceiverHeaders
	join inserted on ReceiverHeaders.ReceiverID = inserted.ReceiverID
where	Inserted.ReceiverNumber = '0'
GO
ALTER TABLE [dbo].[ReceiverHeaders] ADD CONSTRAINT [PK__ReceiverHeaders__2DD28ED6] PRIMARY KEY CLUSTERED  ([ReceiverID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReceiverHeaders] ADD CONSTRAINT [UQ__ReceiverHeaders__2EC6B30F] UNIQUE NONCLUSTERED  ([ReceiverNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ReceiverHeaders_Status] ON [dbo].[ReceiverHeaders] ([Status]) INCLUDE ([ReceiverID]) ON [PRIMARY]
GO
