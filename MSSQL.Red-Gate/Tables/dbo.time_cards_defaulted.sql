CREATE TABLE [dbo].[time_cards_defaulted]
(
[payroll_cycle] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[payroll_date] [datetime] NOT NULL,
[time_card_group_crew] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[time_card_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[time_cards_defaulted] ADD CONSTRAINT [pk_time_cards_defaulted] PRIMARY KEY CLUSTERED  ([payroll_cycle], [payroll_date], [time_card_group_crew], [time_card_type], [employee]) ON [PRIMARY]
GO
