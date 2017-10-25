CREATE TABLE [dbo].[cert_training_schedules]
(
[certificate] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[class_date] [datetime] NOT NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[class_size] [int] NULL,
[instructor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[starting_time] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cert_training_schedules] ADD CONSTRAINT [pk_cert_training_schedules] PRIMARY KEY CLUSTERED  ([certificate], [class_date], [location], [starting_time]) ON [PRIMARY]
GO
