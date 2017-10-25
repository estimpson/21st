CREATE TABLE [dbo].[lease_spaces]
(
[lease_space] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lease_space_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lease_building] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dimensions] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_date] [datetime] NULL,
[end_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lease_spaces] ADD CONSTRAINT [pk_lease_spaces] PRIMARY KEY CLUSTERED  ([lease_space]) ON [PRIMARY]
GO
