CREATE TABLE [custom].[part_WIP_Imported]
(
[Customer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Part] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Price] [numeric] (12, 6) NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__part_WIP___RowCr__2AA37E75] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NULL CONSTRAINT [DF__part_WIP___RowCr__2B97A2AE] DEFAULT (user_name())
) ON [PRIMARY]
GO
ALTER TABLE [custom].[part_WIP_Imported] ADD CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
