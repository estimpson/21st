CREATE TABLE [dbo].[applicant_scoreboard_notes]
(
[applicant] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position_requisition] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[note_date] [datetime] NOT NULL,
[note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[follow_up_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicant_scoreboard_notes] ADD CONSTRAINT [pk_applicant_scoreboard_notes] PRIMARY KEY CLUSTERED  ([applicant], [position_requisition], [note_date]) ON [PRIMARY]
GO
