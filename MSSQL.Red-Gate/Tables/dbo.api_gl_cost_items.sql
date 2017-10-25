CREATE TABLE [dbo].[api_gl_cost_items]
(
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id3] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_line] [smallint] NOT NULL,
[document_amount] [decimal] (18, 6) NULL,
[document_reference1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_reference2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_remarks] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [numeric] (18, 6) NULL,
[unit_of_measure] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_cost] [decimal] (18, 6) NULL,
[sort_line] [numeric] (8, 2) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[api_gl_cost_items] ADD CONSTRAINT [pk_api_gl_cost_items] PRIMARY KEY CLUSTERED  ([document_type], [document_id1], [document_id2], [document_id3], [document_line]) ON [PRIMARY]
GO
