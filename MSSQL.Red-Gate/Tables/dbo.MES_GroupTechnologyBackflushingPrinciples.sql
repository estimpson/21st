CREATE TABLE [dbo].[MES_GroupTechnologyBackflushingPrinciples]
(
[GroupTechnology] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__MES_Group__Statu__37F0F5ED] DEFAULT ((0)),
[BackflushingPrinciple] [int] NOT NULL CONSTRAINT [DF__MES_Group__Backf__38E51A26] DEFAULT ((0)),
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__MES_Group__RowCr__39D93E5F] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__MES_Group__RowCr__3ACD6298] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__MES_Group__RowMo__3BC186D1] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__MES_Group__RowMo__3CB5AB0A] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MES_GroupTechnologyBackflushingPrinciples] ADD CONSTRAINT [PK__MES_GroupTechnol__35148942] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MES_GroupTechnologyBackflushingPrinciples] ADD CONSTRAINT [UQ__MES_GroupTechnol__3608AD7B] UNIQUE NONCLUSTERED  ([GroupTechnology]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MES_GroupTechnologyBackflushingPrinciples] ADD CONSTRAINT [FK__MES_Group__Group__36FCD1B4] FOREIGN KEY ([GroupTechnology]) REFERENCES [dbo].[group_technology] ([id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
