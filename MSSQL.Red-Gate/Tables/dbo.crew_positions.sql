CREATE TABLE [dbo].[crew_positions]
(
[crew] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[begin_date] [datetime] NOT NULL,
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employee_percent] [numeric] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[crew_positions] ADD CONSTRAINT [pk_crew_positions] PRIMARY KEY CLUSTERED  ([crew], [position_id], [begin_date]) ON [PRIMARY]
GO
