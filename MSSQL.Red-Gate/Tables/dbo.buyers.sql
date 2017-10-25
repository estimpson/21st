CREATE TABLE [dbo].[buyers]
(
[buyer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[buyer_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[buyers] ADD CONSTRAINT [pk_buyers] PRIMARY KEY CLUSTERED  ([buyer]) ON [PRIMARY]
GO
