CREATE TABLE [dbo].[employee_injuries]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[injury_date] [datetime] NOT NULL,
[injury_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[body_part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[injury_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[return_date] [datetime] NULL,
[days_lost] [int] NULL,
[treatment_location] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[treatment_physician] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[treatment_cost] [decimal] (18, 6) NULL,
[treatment_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[osha_report] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[injury_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[supervisor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[division] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crew] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[job_related] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cause] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_injuries] ADD CONSTRAINT [pk_employee_injuries] PRIMARY KEY CLUSTERED  ([employee], [injury_date], [injury_type], [body_part]) ON [PRIMARY]
GO
