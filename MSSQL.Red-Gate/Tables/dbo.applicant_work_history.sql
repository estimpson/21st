CREATE TABLE [dbo].[applicant_work_history]
(
[applicant] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[begin_date] [datetime] NOT NULL,
[end_date] [datetime] NULL,
[company] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[salary] [decimal] (18, 6) NULL,
[position_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicant_work_history] ADD CONSTRAINT [pk_applicant_work_history] PRIMARY KEY CLUSTERED  ([applicant], [position], [begin_date]) ON [PRIMARY]
GO
