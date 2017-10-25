CREATE TABLE [dbo].[application_answers]
(
[position_requisition] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[applicant] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[question_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[question_answer] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[application] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[application_answers] ADD CONSTRAINT [pk_application_answers] PRIMARY KEY CLUSTERED  ([applicant], [position_requisition], [application], [question_id]) ON [PRIMARY]
GO
