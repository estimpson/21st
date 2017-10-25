CREATE TABLE [dbo].[territories]
(
[territory] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[territory_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[territories] ADD CONSTRAINT [pk_territories] PRIMARY KEY CLUSTERED  ([territory]) ON [PRIMARY]
GO
