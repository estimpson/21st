CREATE TABLE [dbo].[employee_positions]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[begin_date] [datetime] NOT NULL,
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[end_date] [datetime] NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primary_position] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fte] [decimal] (18, 6) NULL,
[division] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[import_batch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_positions] ADD CONSTRAINT [pk_employee_positions] PRIMARY KEY CLUSTERED  ([employee], [begin_date], [position]) ON [PRIMARY]
GO
