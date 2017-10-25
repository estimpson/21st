CREATE TABLE [dbo].[time_card_groups]
(
[time_card_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[time_card_group_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entry_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[signature_list] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[time_card_calendar] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[time_card_groups] ADD CONSTRAINT [pk_time_card_groups] PRIMARY KEY CLUSTERED  ([time_card_group]) ON [PRIMARY]
GO
