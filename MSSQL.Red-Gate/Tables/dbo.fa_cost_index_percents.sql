CREATE TABLE [dbo].[fa_cost_index_percents]
(
[replacement_cost_index] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[relative_year] [smallint] NOT NULL,
[relative_percent] [decimal] (5, 2) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_cost_index_percents] ADD CONSTRAINT [pk_fa_cost_index_percents] PRIMARY KEY CLUSTERED  ([replacement_cost_index], [relative_year]) ON [PRIMARY]
GO
