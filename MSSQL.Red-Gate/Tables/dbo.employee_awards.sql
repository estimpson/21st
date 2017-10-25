CREATE TABLE [dbo].[employee_awards]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[award_date] [datetime] NOT NULL,
[award_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[award] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reason] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[award_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[division] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[followup_date] [datetime] NULL,
[followup_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[supervisor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[end_date] [datetime] NULL,
[expire_date] [datetime] NULL,
[union_rep] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employee_awards_identity] [numeric] (18, 0) NOT NULL IDENTITY(1, 1)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_awards] ADD CONSTRAINT [pk_employee_awards] PRIMARY KEY CLUSTERED  ([employee], [award_date], [award_type], [award], [employee_awards_identity]) ON [PRIMARY]
GO
