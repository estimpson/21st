CREATE TABLE [dbo].[ar_programs]
(
[program] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[program_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ar_programs] ADD CONSTRAINT [pk_ar_programs] PRIMARY KEY CLUSTERED  ([program]) ON [PRIMARY]
GO
