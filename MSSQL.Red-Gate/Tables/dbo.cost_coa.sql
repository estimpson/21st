CREATE TABLE [dbo].[cost_coa]
(
[account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[account_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[profit_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[profit_group_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_3] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_4] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_5] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_6] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_7] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_8] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_9] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_10] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_1_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_2_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_3_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_4_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_5_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_6_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_7_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_8_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_9_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa_level_10_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[account_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_coa] ADD CONSTRAINT [pk_cost_coa] PRIMARY KEY CLUSTERED  ([coa], [account]) ON [PRIMARY]
GO
