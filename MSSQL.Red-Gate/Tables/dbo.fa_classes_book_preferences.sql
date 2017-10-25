CREATE TABLE [dbo].[fa_classes_book_preferences]
(
[fa_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[depreciation_book] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asset_life] [decimal] (12, 5) NULL,
[life_unit_of_measure] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[depreciation_method] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[new_used] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_classes_book_preferences] ADD CONSTRAINT [pk_fa_classes_book_preferences] PRIMARY KEY CLUSTERED  ([fa_class], [depreciation_book]) ON [PRIMARY]
GO
