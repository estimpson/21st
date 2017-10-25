CREATE TABLE [FT].[New22_Buckets_bill_of_material_ec_recessed]
(
[parent_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[part] [varchar] (29) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_datetime] [datetime] NOT NULL,
[type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[quantity] [int] NOT NULL,
[unit_measure] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reference_no] [int] NULL,
[std_qty] [int] NOT NULL,
[scrap_factor] [int] NOT NULL,
[engineering_level] [int] NULL,
[operator] [int] NULL,
[substitute_part] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[date_changed] [datetime] NOT NULL,
[note] [int] NULL
) ON [PRIMARY]
GO
