CREATE TABLE [dbo].[pyhr_locations]
(
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pyhr_locations] ADD CONSTRAINT [pk_pyhr_locations] PRIMARY KEY CLUSTERED  ([location]) ON [PRIMARY]
GO
