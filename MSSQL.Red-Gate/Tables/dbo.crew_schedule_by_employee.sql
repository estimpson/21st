CREATE TABLE [dbo].[crew_schedule_by_employee]
(
[crew] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[work_date] [datetime] NOT NULL,
[position_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[record_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[employee_percent] [decimal] (18, 6) NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[hours] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[crew_schedule_by_employee] ADD CONSTRAINT [pk_crew_schedule_by_employee] PRIMARY KEY CLUSTERED  ([crew], [work_date], [position_id], [employee], [pay_type], [record_type]) ON [PRIMARY]
GO
