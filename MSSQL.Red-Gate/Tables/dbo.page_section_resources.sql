CREATE TABLE [dbo].[page_section_resources]
(
[page] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[page_section] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[page_section_resource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[page_section_resource_type] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[page_section_resource_content] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[page_section_resources] ADD CONSTRAINT [pk_page_section_resources] PRIMARY KEY CLUSTERED  ([page], [page_section], [page_section_resource]) ON [PRIMARY]
GO
