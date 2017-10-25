CREATE TABLE [dbo].[option_groups]
(
[option_group_id] [uniqueidentifier] NOT NULL,
[option_group_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[option_groups] ADD CONSTRAINT [pk_option_groups] PRIMARY KEY CLUSTERED  ([option_group_id]) ON [PRIMARY]
GO
