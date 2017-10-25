CREATE TABLE [dbo].[order_header_inserted]
(
[order_no] [numeric] (8, 0) NOT NULL,
[order_date] [datetime] NOT NULL,
[blanket_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[model_year] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customer_part] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[standard_pack] [numeric] (20, 6) NOT NULL,
[our_cum] [numeric] (20, 6) NOT NULL,
[the_cum] [numeric] (20, 6) NOT NULL,
[order_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[shipped] [numeric] (20, 6) NOT NULL,
[shipped_date] [datetime] NOT NULL,
[shipper] [int] NOT NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[unit] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[revision] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customer_po] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[blanket_qty] [numeric] (20, 6) NOT NULL,
[salesman] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[zone_code] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dock_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[package_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[notes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[shipping_unit] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[line_feed_code] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fab_cum] [numeric] (15, 2) NOT NULL,
[raw_cum] [numeric] (15, 2) NOT NULL,
[fab_date] [datetime] NOT NULL,
[raw_date] [datetime] NOT NULL,
[begin_kanban_number] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[end_kanban_number] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[line11] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[line12] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[line13] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[line14] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[line15] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[line16] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[line17] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[custom01] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[custom02] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[custom03] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cs_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[engineering_level] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[review_date] [datetime] NOT NULL,
[reviewed_by] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[order_header_inserted] ADD CONSTRAINT [PK__order_header_ins__05C49D7C] PRIMARY KEY CLUSTERED  ([order_no], [order_date]) ON [PRIMARY]
GO
