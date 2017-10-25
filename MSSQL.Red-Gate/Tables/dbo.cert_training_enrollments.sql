CREATE TABLE [dbo].[cert_training_enrollments]
(
[certificate] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[class_date] [datetime] NOT NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[enroll_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[graduated] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceu_units] [decimal] (18, 6) NULL,
[class_hours] [decimal] (18, 6) NULL,
[starting_time] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cert_training_enrollments] ADD CONSTRAINT [pk_cert_training_enrollments] PRIMARY KEY CLUSTERED  ([certificate], [class_date], [location], [starting_time], [employee]) ON [PRIMARY]
GO
