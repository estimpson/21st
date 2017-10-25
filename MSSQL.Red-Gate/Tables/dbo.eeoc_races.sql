CREATE TABLE [dbo].[eeoc_races]
(
[eeoc_race] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[eeoc_reporting_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[eeoc_sort] [smallint] NULL,
[eeoc_race_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eeoc_races] ADD CONSTRAINT [pk_eeoc_races] PRIMARY KEY CLUSTERED  ([eeoc_race], [eeoc_reporting_type]) ON [PRIMARY]
GO
