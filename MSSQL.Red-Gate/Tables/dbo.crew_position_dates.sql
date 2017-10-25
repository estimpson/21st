CREATE TABLE [dbo].[crew_position_dates]
(
[crew] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[begin_date] [datetime] NOT NULL,
[end_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[crew_position_dates] ADD CONSTRAINT [pk_crew_position_dates] PRIMARY KEY CLUSTERED  ([crew], [begin_date]) ON [PRIMARY]
GO
