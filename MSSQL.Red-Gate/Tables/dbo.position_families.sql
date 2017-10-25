CREATE TABLE [dbo].[position_families]
(
[position_family] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position_family_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[position_families] ADD CONSTRAINT [pk_position_families] PRIMARY KEY CLUSTERED  ([position_family]) ON [PRIMARY]
GO
