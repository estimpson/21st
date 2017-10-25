CREATE TABLE [dbo].[locations]
(
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[locations] ADD CONSTRAINT [pk_locations] PRIMARY KEY CLUSTERED  ([location]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
