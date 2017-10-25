CREATE TABLE [dbo].[CityPostalWorld]
(
[CountryCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RegionCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[City] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Latitude] [real] NULL,
[Longitude] [real] NULL,
[Active] [int] NULL CONSTRAINT [DF__CityPosta__Activ__772C6562] DEFAULT ((1))
) ON [PRIMARY]
GO
