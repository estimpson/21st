CREATE TABLE [dbo].[sales_terms]
(
[sales_term] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sales_term_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sales_terms] ADD CONSTRAINT [pk_sales_terms] PRIMARY KEY CLUSTERED  ([sales_term]) ON [PRIMARY]
GO
