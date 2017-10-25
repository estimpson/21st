CREATE TABLE [dbo].[sales_agents]
(
[sales_agent] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sales_agent_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[commission_percent] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sales_agents] ADD CONSTRAINT [pk_sales_agents] PRIMARY KEY CLUSTERED  ([sales_agent]) ON [PRIMARY]
GO
