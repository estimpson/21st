CREATE TABLE [dbo].[position_dates]
(
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[begin_date] [datetime] NOT NULL,
[end_date] [datetime] NOT NULL,
[position_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[position_description] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[position_dates] ADD CONSTRAINT [pk_position_dates] PRIMARY KEY CLUSTERED  ([position], [begin_date]) ON [PRIMARY]
GO
