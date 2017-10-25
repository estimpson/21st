CREATE TABLE [dbo].[datawindow_formats]
(
[datawindow_format] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[datawindow_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[column_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[display_order] [smallint] NULL,
[column_heading] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[column_width] [smallint] NULL,
[column_enabled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[column_visible] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allow_visible_change] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allow_enabled_change] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[force_enabled_when_visible] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[datawindow_formats] ADD CONSTRAINT [pk_datawindow_formats] PRIMARY KEY CLUSTERED  ([datawindow_format], [datawindow_name], [column_name]) ON [PRIMARY]
GO
