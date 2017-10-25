CREATE TABLE [dbo].[lease_sites]
(
[lease_site] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lease_site_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[lease_sites] ADD CONSTRAINT [pk_lease_sites] PRIMARY KEY CLUSTERED  ([lease_site]) ON [PRIMARY]
GO
