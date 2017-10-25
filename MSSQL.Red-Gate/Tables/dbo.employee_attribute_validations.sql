CREATE TABLE [dbo].[employee_attribute_validations]
(
[validation_table_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[valid_value] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_attribute_validations] ADD CONSTRAINT [pk_employee_attribute_validations] PRIMARY KEY CLUSTERED  ([validation_table_name], [valid_value]) ON [PRIMARY]
GO
