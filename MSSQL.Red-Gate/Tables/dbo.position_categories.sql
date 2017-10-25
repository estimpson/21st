CREATE TABLE [dbo].[position_categories]
(
[position_category] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position_category_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[position_categories] ADD CONSTRAINT [pk_position_categories] PRIMARY KEY CLUSTERED  ([position_category]) ON [PRIMARY]
GO
