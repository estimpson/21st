CREATE TABLE [dbo].[MES_PartBackflushingPrinciples]
(
[Part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__MES_PartB__Statu__2E678BB3] DEFAULT ((0)),
[BackflushingPrinciple] [int] NOT NULL CONSTRAINT [DF__MES_PartB__Backf__2F5BAFEC] DEFAULT ((0)),
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__MES_PartB__RowCr__304FD425] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__MES_PartB__RowCr__3143F85E] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__MES_PartB__RowMo__32381C97] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__MES_PartB__RowMo__332C40D0] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MES_PartBackflushingPrinciples] ADD CONSTRAINT [PK__MES_PartBackflus__2B8B1F08] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MES_PartBackflushingPrinciples] ADD CONSTRAINT [UQ__MES_PartBackflus__2C7F4341] UNIQUE NONCLUSTERED  ([Part]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MES_PartBackflushingPrinciples] ADD CONSTRAINT [FK__MES_PartBa__Part__2D73677A] FOREIGN KEY ([Part]) REFERENCES [dbo].[part] ([part]) ON DELETE CASCADE ON UPDATE CASCADE
GO
