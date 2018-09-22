CREATE TABLE [dbo].[comp_items]
(
[part] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost] [numeric] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[comp_items] ADD CONSTRAINT [PK_comp_items] PRIMARY KEY CLUSTERED  ([part]) ON [PRIMARY]
GO
