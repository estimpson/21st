CREATE TABLE [dbo].[ar_program_events]
(
[program] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[program_event] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[shipping_handling_amount] [numeric] (18, 6) NULL,
[program_event_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ar_program_events] ADD CONSTRAINT [pk_ar_program_events] PRIMARY KEY CLUSTERED  ([program], [program_event]) ON [PRIMARY]
GO
