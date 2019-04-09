CREATE TABLE [dbo].[review_forms]
(
[review_form] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[review_form_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[file_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[review_forms] ADD CONSTRAINT [pk_review_forms] PRIMARY KEY CLUSTERED  ([review_form]) ON [PRIMARY]
GO
