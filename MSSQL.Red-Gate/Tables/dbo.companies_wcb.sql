CREATE TABLE [dbo].[companies_wcb]
(
[wcb_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[province_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wcb_business_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wcb_group_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[security_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[companies_wcb] ADD CONSTRAINT [pk_companies_wcb] PRIMARY KEY CLUSTERED  ([wcb_group], [company]) ON [PRIMARY]
GO
