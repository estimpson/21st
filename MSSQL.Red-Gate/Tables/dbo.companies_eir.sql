CREATE TABLE [dbo].[companies_eir]
(
[eir_business_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[business_number_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_phone] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_extension] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[companies_eir] ADD CONSTRAINT [pk_companies_eir] PRIMARY KEY CLUSTERED  ([eir_business_number]) ON [PRIMARY]
GO
