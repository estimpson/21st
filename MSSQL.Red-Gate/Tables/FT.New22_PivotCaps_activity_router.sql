CREATE TABLE [FT].[New22_PivotCaps_activity_router]
(
[parent_part] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sequence] [numeric] (5, 0) NOT NULL,
[code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[part] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[labor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[material] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_bill] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[group_location] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[process] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[doc1] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[doc2] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[doc3] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[doc4] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost] [numeric] (20, 6) NULL,
[price] [numeric] (20, 6) NULL,
[cost_price_factor] [numeric] (20, 6) NULL,
[time_stamp] [datetime] NULL
) ON [PRIMARY]
GO
