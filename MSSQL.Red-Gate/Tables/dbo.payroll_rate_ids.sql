CREATE TABLE [dbo].[payroll_rate_ids]
(
[rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[empower_rate_style] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[freq_per_year] [int] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[rate_id_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[security_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[import_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[payroll_rate_ids] ADD CONSTRAINT [pk_payroll_rate_ids] PRIMARY KEY CLUSTERED  ([rate_id]) ON [PRIMARY]
GO
