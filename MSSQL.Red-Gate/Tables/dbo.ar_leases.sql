CREATE TABLE [dbo].[ar_leases]
(
[lease] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lease_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frequency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lease_original_date] [datetime] NULL,
[lease_start_date] [datetime] NULL,
[lease_expire_date] [datetime] NULL,
[lease_notify_date] [datetime] NULL,
[rate_expire_date] [datetime] NULL,
[rate_notify_date] [datetime] NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[ship_to_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_cycle] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[monday_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tuesday_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wednesday_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[thursday_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[friday_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[saturday_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sunday_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ar_leases] ADD CONSTRAINT [pk_ar_leases] PRIMARY KEY CLUSTERED  ([lease]) ON [PRIMARY]
GO
