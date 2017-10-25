CREATE TABLE [dbo].[selection_form_values]
(
[selection_form_id] [int] NOT NULL,
[control_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[control_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[selection_form_values] ADD CONSTRAINT [pk_selection_form_values] PRIMARY KEY CLUSTERED  ([selection_form_id], [control_id]) ON [PRIMARY]
GO
