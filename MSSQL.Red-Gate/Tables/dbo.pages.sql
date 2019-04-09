CREATE TABLE [dbo].[pages]
(
[page] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[page_description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[page_keywords] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[page_title] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[menu_option] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pages] ADD CONSTRAINT [pk_pages] PRIMARY KEY CLUSTERED  ([page]) ON [PRIMARY]
GO
