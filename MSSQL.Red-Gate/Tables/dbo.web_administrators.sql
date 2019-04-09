CREATE TABLE [dbo].[web_administrators]
(
[web_administrator] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[web_administrators] ADD CONSTRAINT [pk_web_administrators] PRIMARY KEY CLUSTERED  ([web_administrator]) ON [PRIMARY]
GO
