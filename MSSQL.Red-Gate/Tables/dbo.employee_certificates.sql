CREATE TABLE [dbo].[employee_certificates]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[certificate] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[certificate_date] [datetime] NOT NULL,
[expire_date] [datetime] NULL,
[rating] [decimal] (18, 6) NULL,
[certificate_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[class_date] [datetime] NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hours_of_training] [decimal] (18, 6) NULL,
[ceu_units] [decimal] (18, 6) NULL,
[training_dollars_spent] [decimal] (18, 6) NULL,
[cert_identity] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[employee_certificates] ADD CONSTRAINT [pk_employee_certificates] PRIMARY KEY CLUSTERED  ([employee], [certificate], [certificate_date], [cert_identity]) ON [PRIMARY]
GO
