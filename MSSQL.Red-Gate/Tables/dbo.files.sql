CREATE TABLE [dbo].[files]
(
[file_id] [uniqueidentifier] NOT NULL,
[file_name] [varchar] (225) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[content_type] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[content_length] [int] NULL,
[content] [image] NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[files] ADD CONSTRAINT [pk_files] PRIMARY KEY CLUSTERED  ([file_id]) ON [PRIMARY]
GO
