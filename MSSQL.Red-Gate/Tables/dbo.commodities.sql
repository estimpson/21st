CREATE TABLE [dbo].[commodities]
(
[commodity] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[commodity_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodities] ADD CONSTRAINT [pk_commodities] PRIMARY KEY CLUSTERED  ([commodity]) ON [PRIMARY]
GO
