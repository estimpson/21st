CREATE TABLE [dbo].[crew_shifts]
(
[shift_worked] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[shift_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[crew_shifts] ADD CONSTRAINT [pk_crew_shifts] PRIMARY KEY CLUSTERED  ([shift_worked]) ON [PRIMARY]
GO
