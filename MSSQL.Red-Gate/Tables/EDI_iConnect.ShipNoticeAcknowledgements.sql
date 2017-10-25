CREATE TABLE [EDI_iConnect].[ShipNoticeAcknowledgements]
(
[RawDocumentGUID] [uniqueidentifier] NOT NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__ShipNotic__Statu__32470242] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__ShipNotice__Type__333B267B] DEFAULT ((0)),
[DocumentImportDT] [datetime] NULL,
[ASN_Number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipDate] [datetime] NULL,
[SupplierCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AcknowledgementStatus] [int] NULL,
[ValidationOutput] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__ShipNotic__RowCr__342F4AB4] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ShipNotic__RowCr__35236EED] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__ShipNotic__RowMo__36179326] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__ShipNotic__RowMo__370BB75F] DEFAULT (suser_name())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [EDI_iConnect].[ShipNoticeAcknowledgements] ADD CONSTRAINT [PK__ShipNoti__FFEE74513F2D3C6E] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [EDI_iConnect].[ShipNoticeAcknowledgements] ADD CONSTRAINT [UQ__ShipNoti__ABAFD682FA95C078] UNIQUE NONCLUSTERED  ([RawDocumentGUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ShipNoticeAcknowledgements_1] ON [EDI_iConnect].[ShipNoticeAcknowledgements] ([Status]) ON [PRIMARY]
GO
