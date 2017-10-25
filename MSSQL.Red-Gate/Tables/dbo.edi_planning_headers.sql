CREATE TABLE [dbo].[edi_planning_headers]
(
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[so_release] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_ship_date] [datetime] NULL,
[last_ship_qty] [numeric] (18, 6) NULL,
[cum_ytd_ship_qty] [numeric] (18, 6) NULL,
[cum_ytd_reqd_qty] [numeric] (18, 6) NULL,
[fab_qty] [numeric] (18, 6) NULL,
[fab_date] [datetime] NULL,
[mat_qty] [numeric] (18, 6) NULL,
[mat_date] [datetime] NULL,
[horizon_start_date] [datetime] NULL,
[horizon_end_date] [datetime] NULL,
[cum_start_date] [datetime] NULL,
[cum_end_date] [datetime] NULL,
[edi_planning_comment] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customer_po] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_release] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_dest_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[release_date] [datetime] NULL,
[model_year] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[supplier_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dock_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[control_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_planning_headers] ADD CONSTRAINT [pk_edi_planning_headers] PRIMARY KEY CLUSTERED  ([sales_order], [so_release], [item]) ON [PRIMARY]
GO
