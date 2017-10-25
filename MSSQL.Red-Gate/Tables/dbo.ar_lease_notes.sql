CREATE TABLE [dbo].[ar_lease_notes]
(
[lease] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[note_date] [datetime] NOT NULL,
[note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[follow_up_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ar_lease_notes] ADD CONSTRAINT [pk_ar_lease_notes] PRIMARY KEY CLUSTERED  ([lease], [note_date]) ON [PRIMARY]
GO
