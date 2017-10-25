CREATE TABLE [dbo].[identifier_types]
(
[identifier_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[system] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[installed_module] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[identifier_types] ADD CONSTRAINT [pk_identifier_types] PRIMARY KEY CLUSTERED  ([identifier_type], [system]) ON [PRIMARY]
GO
