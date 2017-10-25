CREATE TABLE [dbo].[employment_types]
(
[employment_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[employment_type_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eeoc_trainee] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eeoc_full_time] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_graduate_assistant] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employment_types] ADD CONSTRAINT [pk_employment_types] PRIMARY KEY CLUSTERED  ([employment_type]) ON [PRIMARY]
GO
