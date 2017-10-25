CREATE TABLE [dbo].[cost_identifier_notes]
(
[cost_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cost_sub] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[note_date] [datetime] NOT NULL,
[cost_id_note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[follow_up_date] [datetime] NULL,
[resolved_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_identifier_notes] ADD CONSTRAINT [pk_cost_identifier_notes] PRIMARY KEY CLUSTERED  ([cost_id], [cost_sub], [note_date]) ON [PRIMARY]
GO
