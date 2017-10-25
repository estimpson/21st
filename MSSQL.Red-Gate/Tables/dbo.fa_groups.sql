CREATE TABLE [dbo].[fa_groups]
(
[asset_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_groups] ADD CONSTRAINT [pk_fa_groups] PRIMARY KEY CLUSTERED  ([asset_group]) ON [PRIMARY]
GO
