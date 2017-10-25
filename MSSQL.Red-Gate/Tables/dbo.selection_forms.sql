CREATE TABLE [dbo].[selection_forms]
(
[selection_form_id] [int] NOT NULL,
[selection_form] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[user_id] [uniqueidentifier] NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[selection_forms] ADD CONSTRAINT [pk_selection_forms] PRIMARY KEY CLUSTERED  ([selection_form_id]) ON [PRIMARY]
GO
