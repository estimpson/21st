CREATE TABLE [dbo].[page_sections]
(
[page] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[page_section] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[page_section_type] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[css_class] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[padding] [int] NULL,
[sort_order] [decimal] (18, 6) NULL,
[is_enabled] [bit] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[page_sections] ADD CONSTRAINT [pk_page_sections] PRIMARY KEY CLUSTERED  ([page], [page_section]) ON [PRIMARY]
GO
