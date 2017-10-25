CREATE TABLE [dbo].[so_releases]
(
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[so_release] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[so_release_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_date] [datetime] NULL,
[so_required_date] [datetime] NULL,
[order_revision_date] [datetime] NULL,
[order_revision_number] [smallint] NULL,
[order_notification] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[printed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[batch] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_file_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_dock] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_accum_start_date] [datetime] NULL,
[edi_accum_end_date] [datetime] NULL,
[hold_document] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hold_reason] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_model_year] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[so_releases] ADD CONSTRAINT [pk_so_releases] PRIMARY KEY CLUSTERED  ([sales_order], [so_release]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [so_releases_batch] ON [dbo].[so_releases] ([batch]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [so_releases_id] ON [dbo].[so_releases] ([so_release_id]) ON [PRIMARY]
GO
