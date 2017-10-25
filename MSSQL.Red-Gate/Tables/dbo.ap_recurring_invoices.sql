CREATE TABLE [dbo].[ap_recurring_invoices]
(
[vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[invoice] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[frequency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ap_recurring_invoices] ADD CONSTRAINT [pk_ap_recurring_invoices] PRIMARY KEY CLUSTERED  ([vendor], [invoice]) ON [PRIMARY]
GO
