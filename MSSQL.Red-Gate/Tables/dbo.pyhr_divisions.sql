CREATE TABLE [dbo].[pyhr_divisions]
(
[division] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[division_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pyhr_divisions] ADD CONSTRAINT [pk_pyhr_divisions] PRIMARY KEY CLUSTERED  ([division]) ON [PRIMARY]
GO
