CREATE TABLE [dbo].[degrees]
(
[degree] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[degrees] ADD CONSTRAINT [pk_degrees] PRIMARY KEY CLUSTERED  ([degree]) ON [PRIMARY]
GO
