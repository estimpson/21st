CREATE TABLE [dbo].[t4_form_published]
(
[company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[calendar_year] [int] NOT NULL,
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[business_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[province_of_employment] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[file_id] [uniqueidentifier] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t4_form_published] ADD CONSTRAINT [pk_t4_form_published] PRIMARY KEY CLUSTERED  ([company], [calendar_year], [employee], [business_number], [province_of_employment]) ON [PRIMARY]
GO
