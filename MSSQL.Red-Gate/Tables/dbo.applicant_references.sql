CREATE TABLE [dbo].[applicant_references]
(
[applicant] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[company] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[contact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reference_comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicant_references] ADD CONSTRAINT [pk_applicant_references] PRIMARY KEY CLUSTERED  ([applicant], [company], [phone], [contact]) ON [PRIMARY]
GO
