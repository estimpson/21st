CREATE TABLE [dbo].[cost_id_security]
(
[user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cost_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_id_security] ADD CONSTRAINT [pk_cost_id_security] PRIMARY KEY CLUSTERED  ([user_id], [cost_id]) ON [PRIMARY]
GO
