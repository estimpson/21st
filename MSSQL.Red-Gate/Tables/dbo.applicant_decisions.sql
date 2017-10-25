CREATE TABLE [dbo].[applicant_decisions]
(
[applicant] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[decision_date] [datetime] NULL,
[decision] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[decision_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position_requisition] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicant_decisions] ADD CONSTRAINT [pk_applicant_decisions] PRIMARY KEY CLUSTERED  ([applicant], [position_requisition]) ON [PRIMARY]
GO
