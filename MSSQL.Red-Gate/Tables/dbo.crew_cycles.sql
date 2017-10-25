CREATE TABLE [dbo].[crew_cycles]
(
[crew] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cycle_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[number_of_days] [int] NOT NULL,
[on_or_off] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[shift_worked] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[crew_cycles] ADD CONSTRAINT [pk_crew_cycles] PRIMARY KEY CLUSTERED  ([crew], [cycle_id], [number_of_days], [on_or_off]) ON [PRIMARY]
GO
