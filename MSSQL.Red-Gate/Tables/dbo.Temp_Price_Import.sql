CREATE TABLE [dbo].[Temp_Price_Import]
(
[Part] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Price] [numeric] (12, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Temp_Price_Import] ADD CONSTRAINT [PK_Temp_Price_Import] PRIMARY KEY CLUSTERED  ([Part]) ON [PRIMARY]
GO
