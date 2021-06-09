CREATE TABLE [dbo].[Temp_IRWIN_Pricing]
(
[Part] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColorAbreviation] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColorName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BasePart] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Price] [numeric] (10, 8) NOT NULL,
[EffectiveDate] [datetime] NULL,
[LastUpdatedDT] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Temp_IRWIN_Pricing] ADD CONSTRAINT [PK_Temp_IRWIN_Pricing] PRIMARY KEY CLUSTERED  ([Part]) ON [PRIMARY]
GO
