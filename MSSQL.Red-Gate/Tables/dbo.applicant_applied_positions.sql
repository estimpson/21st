CREATE TABLE [dbo].[applicant_applied_positions]
(
[applicant] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[applied_date] [datetime] NOT NULL,
[position_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position_requisition] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[application] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicant_applied_positions] ADD CONSTRAINT [pk_applicant_applied_positions] PRIMARY KEY CLUSTERED  ([applicant], [position_requisition]) ON [PRIMARY]
GO
