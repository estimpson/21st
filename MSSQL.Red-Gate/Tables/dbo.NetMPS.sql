CREATE TABLE [dbo].[NetMPS]
(
[Status] [int] NOT NULL CONSTRAINT [DF__NetMPS_Ne__Statu__599212A4] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__NetMPS_New__Type__5A8636DD] DEFAULT ((0)),
[OrderNo] [int] NOT NULL CONSTRAINT [DF__NetMPS_Ne__Order__5B7A5B16] DEFAULT ((-1)),
[LineID] [int] NOT NULL,
[Part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RequiredDT] [datetime] NOT NULL,
[GrossDemand] [numeric] (30, 12) NOT NULL,
[Balance] [numeric] (30, 12) NOT NULL,
[OnHandQty] [numeric] (30, 12) NOT NULL CONSTRAINT [DF__NetMPS_Ne__OnHan__5C6E7F4F] DEFAULT ((0)),
[InTransitQty] [numeric] (30, 12) NOT NULL CONSTRAINT [DF__NetMPS_Ne__InTra__5D62A388] DEFAULT ((0)),
[WIPQty] [numeric] (30, 12) NOT NULL CONSTRAINT [DF__NetMPS_Ne__WIPQt__5E56C7C1] DEFAULT ((0)),
[LowLevel] [int] NOT NULL,
[Sequence] [int] NOT NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__NetMPS_Ne__RowCr__5F4AEBFA] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__NetMPS_Ne__RowCr__603F1033] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__NetMPS_Ne__RowMo__6133346C] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__NetMPS_Ne__RowMo__622758A5] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NetMPS] ADD CONSTRAINT [PK__NetMPS_N__FFEE745122E53A3E] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
