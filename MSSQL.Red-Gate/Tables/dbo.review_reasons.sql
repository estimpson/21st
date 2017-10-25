CREATE TABLE [dbo].[review_reasons]
(
[review_reason] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[review_reasons] ADD CONSTRAINT [pk_review_reasons] PRIMARY KEY CLUSTERED  ([review_reason]) ON [PRIMARY]
GO
