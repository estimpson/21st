CREATE TABLE [dbo].[employee_equipment]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[equipment_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[equipment_description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[equipment_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[equipment_model] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[equipment_serial_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[issued_date] [datetime] NULL,
[return_date] [datetime] NULL,
[renew_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[entry_date] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_equipment] ADD CONSTRAINT [pk_employee_equipment] PRIMARY KEY CLUSTERED  ([employee], [equipment_code], [entry_date]) ON [PRIMARY]
GO
