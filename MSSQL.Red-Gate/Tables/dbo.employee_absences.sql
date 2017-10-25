CREATE TABLE [dbo].[employee_absences]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pay_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[date_worked] [datetime] NOT NULL,
[entry_date] [datetime] NOT NULL,
[payroll_date] [datetime] NULL,
[absence_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[supervisor] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours] [decimal] (18, 6) NULL,
[cost] [decimal] (18, 6) NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[absence_identity] [int] NOT NULL IDENTITY(1, 1),
[time_card_identity] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_absences] ADD CONSTRAINT [pk_employee_absences] PRIMARY KEY CLUSTERED  ([employee], [pay_type], [date_worked], [entry_date], [absence_identity]) ON [PRIMARY]
GO
