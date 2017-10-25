CREATE TABLE [dbo].[so_scoreboard_notes]
(
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[note_date] [datetime] NOT NULL,
[sales_order_note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[follow_up_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[so_scoreboard_notes] ADD CONSTRAINT [pk_so_scoreboard_notes] PRIMARY KEY CLUSTERED  ([sales_order], [note_date]) ON [PRIMARY]
GO
