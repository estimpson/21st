CREATE TABLE [dbo].[edi_ship_schedule_headers]
(
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[so_release] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_ship_date] [datetime] NULL,
[last_ship_qty] [numeric] (18, 6) NULL,
[cum_ytd_ship_qty] [numeric] (18, 6) NULL,
[cum_ytd_reqd_qty] [numeric] (18, 6) NULL,
[edi_ship_schedule_comment] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_ship_schedule_headers] ADD CONSTRAINT [pk_edi_ship_schedule_headers] PRIMARY KEY CLUSTERED  ([sales_order], [so_release]) ON [PRIMARY]
GO
