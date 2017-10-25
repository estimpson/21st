CREATE TABLE [dbo].[po_scoreboard_notes]
(
[purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[note_date] [datetime] NOT NULL,
[purchase_order_note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[follow_up_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[po_scoreboard_notes] ADD CONSTRAINT [pk_po_scoreboard_notes] PRIMARY KEY NONCLUSTERED  ([purchase_order], [note_date]) ON [PRIMARY]
GO
