CREATE TABLE [dbo].[employee_reviews]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scheduled_date] [datetime] NOT NULL,
[completed_date] [datetime] NULL,
[effective_date] [datetime] NULL,
[reviewer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[review_reason] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[review_comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[review_rating] [decimal] (18, 6) NULL,
[rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_effective_date] [datetime] NULL,
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position_effective] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lump_sum_payment] [decimal] (18, 6) NULL,
[review_document] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position_review_document] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_reviews] ADD CONSTRAINT [pk_employee_reviews] PRIMARY KEY CLUSTERED  ([employee], [scheduled_date]) ON [PRIMARY]
GO
