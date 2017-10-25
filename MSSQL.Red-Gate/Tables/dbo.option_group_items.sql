CREATE TABLE [dbo].[option_group_items]
(
[option_group_id] [uniqueidentifier] NOT NULL,
[option_id] [uniqueidentifier] NOT NULL,
[restricted_tabs] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[read_only] [bit] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[option_group_items] ADD CONSTRAINT [pk_option_group_items] PRIMARY KEY CLUSTERED  ([option_group_id], [option_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[option_group_items] ADD CONSTRAINT [FK_option_group_items_options] FOREIGN KEY ([option_id]) REFERENCES [dbo].[options] ([option_id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
