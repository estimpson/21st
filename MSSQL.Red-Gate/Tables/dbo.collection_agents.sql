CREATE TABLE [dbo].[collection_agents]
(
[collection_agent] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[collection_agent_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[collection_agents] ADD CONSTRAINT [pk_collection_agents] PRIMARY KEY CLUSTERED  ([collection_agent]) ON [PRIMARY]
GO
