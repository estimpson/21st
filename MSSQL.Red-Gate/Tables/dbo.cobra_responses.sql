CREATE TABLE [dbo].[cobra_responses]
(
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[social_security] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[event_date] [datetime] NOT NULL,
[enrolled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ending_coverage_date] [datetime] NULL,
[notify_date] [datetime] NULL,
[response_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cobra_responses] ADD CONSTRAINT [pk_cobra_responses] PRIMARY KEY CLUSTERED  ([employee], [social_security], [event], [event_date]) ON [PRIMARY]
GO
