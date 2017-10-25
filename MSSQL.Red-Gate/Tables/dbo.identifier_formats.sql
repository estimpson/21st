CREATE TABLE [dbo].[identifier_formats]
(
[identifier_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[identifier_format] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prefix] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[starting_number] [int] NULL,
[increment_by] [smallint] NULL,
[maximum_number] [int] NULL,
[next_number] [int] NULL,
[suffix] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[identifier_formats] ADD CONSTRAINT [pk_identifier_formats] PRIMARY KEY CLUSTERED  ([identifier_type], [identifier_format]) ON [PRIMARY]
GO
