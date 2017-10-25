CREATE TABLE [dbo].[salary_grades]
(
[grade] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[minimum_salary] [decimal] (18, 6) NULL,
[midpoint_salary] [decimal] (18, 6) NULL,
[maximum_salary] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[salary_grades] ADD CONSTRAINT [pk_salary_grades] PRIMARY KEY CLUSTERED  ([grade]) ON [PRIMARY]
GO
