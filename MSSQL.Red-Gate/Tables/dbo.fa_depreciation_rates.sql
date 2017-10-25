CREATE TABLE [dbo].[fa_depreciation_rates]
(
[depreciation_method] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[in_service_year] [smallint] NOT NULL,
[in_service_month] [smallint] NOT NULL,
[recovery_year] [smallint] NOT NULL,
[depreciation_rate] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_depreciation_rates] ADD CONSTRAINT [pk_fa_depreciation_rates] PRIMARY KEY CLUSTERED  ([depreciation_method], [in_service_year], [in_service_month], [recovery_year]) ON [PRIMARY]
GO
