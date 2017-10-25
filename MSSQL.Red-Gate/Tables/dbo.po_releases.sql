CREATE TABLE [dbo].[po_releases]
(
[purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[po_release] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[po_release_id] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[release_date] [datetime] NULL,
[printed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[po_releases] ADD CONSTRAINT [pk_po_releases] PRIMARY KEY CLUSTERED  ([purchase_order], [po_release]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [po_releases_id] ON [dbo].[po_releases] ([po_release_id]) ON [PRIMARY]
GO
