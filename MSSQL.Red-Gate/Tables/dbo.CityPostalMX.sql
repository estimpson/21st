CREATE TABLE [dbo].[CityPostalMX]
(
[RegionCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PostalCode] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[City] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Latitude] [real] NULL,
[Longitude] [real] NULL
) ON [PRIMARY]
GO
