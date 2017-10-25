CREATE TABLE [dbo].[freight_terms]
(
[freight_term] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[freight_term_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[freight_terms] ADD CONSTRAINT [pk_freight_terms] PRIMARY KEY CLUSTERED  ([freight_term]) ON [PRIMARY]
GO
