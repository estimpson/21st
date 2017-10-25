CREATE TABLE [dbo].[application_questions]
(
[application] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[question_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[question_page] [int] NULL,
[line_no] [int] NULL,
[question_text] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[validate_style] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[validate_object] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[answer_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[application_questions] ADD CONSTRAINT [pk_application_questions] PRIMARY KEY CLUSTERED  ([application], [question_id]) ON [PRIMARY]
GO
