CREATE TABLE [dbo].[crews]
(
[crew] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[crew_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[division] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entry_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schedule_start_day] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[signature_list] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[crews] ADD CONSTRAINT [pk_crews] PRIMARY KEY CLUSTERED  ([crew]) ON [PRIMARY]
GO
