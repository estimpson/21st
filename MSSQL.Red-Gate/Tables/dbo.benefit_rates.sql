CREATE TABLE [dbo].[benefit_rates]
(
[benefit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[age_years] [smallint] NOT NULL,
[age_months] [smallint] NOT NULL,
[rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_unit] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[benefit_rates] ADD CONSTRAINT [pk_benefit_rates] PRIMARY KEY CLUSTERED  ([benefit], [age_years], [age_months]) ON [PRIMARY]
GO
