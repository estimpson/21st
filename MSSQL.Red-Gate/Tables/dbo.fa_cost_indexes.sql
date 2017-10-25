CREATE TABLE [dbo].[fa_cost_indexes]
(
[replacement_cost_index] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cost_index_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[base_year] [smallint] NULL,
[base_percent] [decimal] (5, 2) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_cost_indexes] ADD CONSTRAINT [pk_fa_cost_indexes] PRIMARY KEY CLUSTERED  ([replacement_cost_index]) ON [PRIMARY]
GO
