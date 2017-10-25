CREATE TABLE [FT].[New22_Seat_bill_of_material_ec]
(
[parent_part] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[part] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_datetime] [datetime] NOT NULL,
[type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [numeric] (38, 6) NULL,
[unit_measure] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reference_no] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[std_qty] [numeric] (38, 6) NULL,
[scrap_factor] [numeric] (20, 6) NULL,
[engineering_level] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[operator] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[substitute_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_changed] [datetime] NULL,
[note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
