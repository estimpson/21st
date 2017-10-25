CREATE TABLE [dbo].[cost_identifiers]
(
[cost_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_date] [datetime] NULL,
[closed_date] [datetime] NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[percent_complete] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_sub] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fa_asset_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fa_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fa_asset_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fa_asset_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fa_asset_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fa_asset_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[security_company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coa] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_id_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grant_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_identifiers] ADD CONSTRAINT [pk_cost_identifiers] PRIMARY KEY CLUSTERED  ([cost_id], [cost_sub]) ON [PRIMARY]
GO
