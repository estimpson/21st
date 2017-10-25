CREATE TABLE [dbo].[time_card_header_notes]
(
[payroll_cycle] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[time_card_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[payroll_date] [datetime] NOT NULL,
[time_card_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[note_date] [datetime] NOT NULL,
[header_note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[follow_up_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[time_card_header_notes] ADD CONSTRAINT [pk_time_card_header_notes] PRIMARY KEY CLUSTERED  ([payroll_cycle], [time_card_group], [payroll_date], [time_card_type], [note_date]) ON [PRIMARY]
GO
