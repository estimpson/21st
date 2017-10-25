CREATE TABLE [dbo].[crew_call_history]
(
[crew] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scheduled_date] [datetime] NULL,
[call_date_time] [datetime] NOT NULL,
[action_taken] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[called_by] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[call_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[crew_call_history] ADD CONSTRAINT [pk_crew_call_history] PRIMARY KEY CLUSTERED  ([employee], [position], [call_date_time]) ON [PRIMARY]
GO
