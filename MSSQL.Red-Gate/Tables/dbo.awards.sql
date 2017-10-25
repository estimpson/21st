CREATE TABLE [dbo].[awards]
(
[award] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[award_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[award_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[awards] ADD CONSTRAINT [pk_awards] PRIMARY KEY CLUSTERED  ([award], [award_type]) ON [PRIMARY]
GO
