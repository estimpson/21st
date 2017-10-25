CREATE TABLE [dbo].[options]
(
[option_id] [uniqueidentifier] NOT NULL,
[option_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[windows_application] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[windows_enabled] [bit] NULL,
[web_application] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[web_enabled] [bit] NULL,
[mobile_application] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mobile_enabled] [bit] NULL,
[tabs] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[report_id] [int] NULL,
[report_enabled] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[options] ADD CONSTRAINT [pk_options] PRIMARY KEY CLUSTERED  ([option_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[options] ADD CONSTRAINT [FK_options_reports] FOREIGN KEY ([report_id]) REFERENCES [dbo].[reports] ([report_id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
