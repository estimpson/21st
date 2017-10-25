CREATE TABLE [dbo].[applicant_sources]
(
[applicant_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicant_sources] ADD CONSTRAINT [pk_applicant_sources] PRIMARY KEY CLUSTERED  ([applicant_source]) ON [PRIMARY]
GO
