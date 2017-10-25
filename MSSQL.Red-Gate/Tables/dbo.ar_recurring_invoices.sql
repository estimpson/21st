CREATE TABLE [dbo].[ar_recurring_invoices]
(
[document] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[suffix] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frequency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[end_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ar_recurring_invoices] ADD CONSTRAINT [pk_ar_recurring_invoices] PRIMARY KEY CLUSTERED  ([document]) ON [PRIMARY]
GO
