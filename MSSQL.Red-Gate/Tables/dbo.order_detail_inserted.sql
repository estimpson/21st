CREATE TABLE [dbo].[order_detail_inserted]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[order_no] [numeric] (8, 0) NOT NULL,
[sequence] [numeric] (5, 0) NOT NULL,
[part_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [numeric] (20, 6) NULL,
[price] [numeric] (20, 6) NULL,
[notes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[assigned] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipped] [numeric] (20, 6) NULL,
[invoiced] [numeric] (20, 6) NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[our_cum] [numeric] (20, 6) NULL,
[the_cum] [numeric] (20, 6) NULL,
[due_date] [datetime] NULL,
[destination] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[committed_qty] [numeric] (20, 6) NULL,
[row_id] [int] NULL,
[group_no] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost] [numeric] (20, 6) NULL,
[plant] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[release_no] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flag] [int] NULL,
[week_no] [int] NULL,
[std_qty] [numeric] (20, 6) NULL,
[customer_part] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dropship_po] [int] NULL,
[dropship_po_row_id] [int] NULL,
[suffix] [int] NULL,
[packline_qty] [numeric] (20, 6) NULL,
[packaging_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[weight] [numeric] (20, 6) NULL,
[custom01] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom02] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom03] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dimension_qty_string] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[engineering_level] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[box_label] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pallet_label] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alternate_price] [decimal] (20, 6) NULL,
[promise_date] [datetime] NULL
) ON [PRIMARY]
GO
