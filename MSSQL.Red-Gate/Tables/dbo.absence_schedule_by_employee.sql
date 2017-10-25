CREATE TABLE [dbo].[absence_schedule_by_employee]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[week_start_date] [datetime] NOT NULL,
[work_date] [datetime] NOT NULL,
[row_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[hours] [decimal] (18, 6) NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[absence_schedule_by_employee] ADD CONSTRAINT [pk_absence_schedule_by_employee] PRIMARY KEY CLUSTERED  ([employee], [week_start_date], [work_date], [row_id], [pay_type]) ON [PRIMARY]
GO
