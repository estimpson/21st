CREATE TABLE [dbo].[Temp_IRWIN_Pricing_bak1]
(
[Part] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColorAbreviation] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColorName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BasePart] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Price] [numeric] (10, 8) NOT NULL
) ON [PRIMARY]
GO
