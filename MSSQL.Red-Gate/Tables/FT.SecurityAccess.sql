CREATE TABLE [FT].[SecurityAccess]
(
[SecurityID] [uniqueidentifier] NOT NULL,
[ResourceID] [uniqueidentifier] NOT NULL,
[Status] [int] NULL CONSTRAINT [DF__SecurityA__Statu__3BD6956A] DEFAULT ((0)),
[Type] [int] NULL CONSTRAINT [DF__SecurityAc__Type__3CCAB9A3] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [FT].[SecurityAccess] ADD CONSTRAINT [PK__SecurityAccess__3AE27131] PRIMARY KEY CLUSTERED  ([SecurityID], [ResourceID]) ON [PRIMARY]
GO
