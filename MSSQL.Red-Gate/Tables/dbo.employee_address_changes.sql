CREATE TABLE [dbo].[employee_address_changes]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[employee_address_change] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[canceled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[home_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[office_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[home_email_address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[office_email_address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[home_cell_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[office_cell_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_submitted] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_address_changes] ADD CONSTRAINT [pk_employee_address_changes] PRIMARY KEY CLUSTERED  ([employee], [employee_address_change]) ON [PRIMARY]
GO
