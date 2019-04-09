CREATE TABLE [dbo].[applicants]
(
[applicant] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[applicant_last_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[applicant_first_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[applicant_source] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[social_security_number] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[home_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[office_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[birth_date] [datetime] NULL,
[gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[race] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_2_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[file_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_id] [uniqueidentifier] NULL,
[ipeds_ethnic_hispanic] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_race_white] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_race_black] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_race_asian] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_race_indian] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_race_hawaiian] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_non_resident_alien] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipeds_race] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[applicants] ADD CONSTRAINT [pk_applicants] PRIMARY KEY CLUSTERED  ([applicant]) ON [PRIMARY]
GO
