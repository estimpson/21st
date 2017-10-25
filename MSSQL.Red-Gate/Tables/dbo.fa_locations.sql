CREATE TABLE [dbo].[fa_locations]
(
[asset_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asset_location_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location_source] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_locations] ADD CONSTRAINT [pk_fa_locations] PRIMARY KEY CLUSTERED  ([asset_location]) ON [PRIMARY]
GO
