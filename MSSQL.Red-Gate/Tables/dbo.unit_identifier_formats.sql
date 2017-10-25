CREATE TABLE [dbo].[unit_identifier_formats]
(
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[identifier_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[identifier_format] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[unit_identifier_formats] ADD CONSTRAINT [pk_unit_identifier_formats] PRIMARY KEY CLUSTERED  ([unit], [identifier_type]) ON [PRIMARY]
GO
