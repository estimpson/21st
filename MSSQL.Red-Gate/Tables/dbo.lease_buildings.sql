CREATE TABLE [dbo].[lease_buildings]
(
[lease_building] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lease_building_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lease_site] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[lease_buildings] ADD CONSTRAINT [pk_lease_buildings] PRIMARY KEY CLUSTERED  ([lease_building]) ON [PRIMARY]
GO
