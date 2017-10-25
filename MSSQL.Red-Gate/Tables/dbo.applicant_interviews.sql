CREATE TABLE [dbo].[applicant_interviews]
(
[applicant] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[interviewer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[interview_date] [datetime] NOT NULL,
[interview_time] [datetime] NOT NULL,
[completed_date] [datetime] NULL,
[rating] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[interview_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position_requisition] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicant_interviews] ADD CONSTRAINT [pk_applicant_interviews] PRIMARY KEY CLUSTERED  ([applicant], [position_requisition], [interviewer], [interview_date], [interview_time]) ON [PRIMARY]
GO
