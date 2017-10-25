CREATE TABLE [dbo].[injury_types]
(
[injury_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[injury_type_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[report_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[injury_types] ADD CONSTRAINT [pk_injury_types] PRIMARY KEY CLUSTERED  ([injury_type]) ON [PRIMARY]
GO
