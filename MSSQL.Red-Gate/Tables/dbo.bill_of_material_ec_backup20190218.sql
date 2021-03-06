CREATE TABLE [dbo].[bill_of_material_ec_backup20190218]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[LastUser] [sys].[sysname] NOT NULL,
[LastDT] [datetime] NULL,
[parent_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[start_datetime] [datetime] NOT NULL,
[end_datetime] [datetime] NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[quantity] [numeric] (20, 6) NOT NULL,
[unit_measure] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reference_no] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[std_qty] [numeric] (20, 6) NULL,
[scrap_factor] [numeric] (20, 6) NOT NULL,
[engineering_level] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[operator] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[substitute_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_changed] [datetime] NOT NULL,
[note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
