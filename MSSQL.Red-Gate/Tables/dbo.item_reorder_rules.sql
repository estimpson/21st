CREATE TABLE [dbo].[item_reorder_rules]
(
[item_reorder_rule] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reorder_rule_style] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[season_offset_jan] [int] NULL,
[season_offset_feb] [int] NULL,
[season_offset_mar] [int] NULL,
[season_offset_apr] [int] NULL,
[season_offset_may] [int] NULL,
[season_offset_jun] [int] NULL,
[season_offset_jul] [int] NULL,
[season_offset_aug] [int] NULL,
[season_offset_sep] [int] NULL,
[season_offset_oct] [int] NULL,
[season_offset_nov] [int] NULL,
[season_offset_dec] [int] NULL,
[reorder_percent_jan] [decimal] (18, 6) NULL,
[reorder_percent_feb] [decimal] (18, 6) NULL,
[reorder_percent_mar] [decimal] (18, 6) NULL,
[reorder_percent_apr] [decimal] (18, 6) NULL,
[reorder_percent_may] [decimal] (18, 6) NULL,
[reorder_percent_jun] [decimal] (18, 6) NULL,
[reorder_percent_jul] [decimal] (18, 6) NULL,
[reorder_percent_aug] [decimal] (18, 6) NULL,
[reorder_percent_sep] [decimal] (18, 6) NULL,
[reorder_percent_oct] [decimal] (18, 6) NULL,
[reorder_percent_nov] [decimal] (18, 6) NULL,
[reorder_percent_dec] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[item_reorder_rules] ADD CONSTRAINT [pk_item_reorder_rules] PRIMARY KEY CLUSTERED  ([item_reorder_rule]) ON [PRIMARY]
GO
