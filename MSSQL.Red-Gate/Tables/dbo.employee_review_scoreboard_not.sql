CREATE TABLE [dbo].[employee_review_scoreboard_not]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scheduled_date] [datetime] NOT NULL,
[note_date] [datetime] NOT NULL,
[employee_review_note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[follow_up_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_review_scoreboard_not] ADD CONSTRAINT [pk_employee_review_scoreboard_not] PRIMARY KEY NONCLUSTERED  ([employee], [scheduled_date], [note_date]) ON [PRIMARY]
GO
