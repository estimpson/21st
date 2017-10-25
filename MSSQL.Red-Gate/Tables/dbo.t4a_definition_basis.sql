CREATE TABLE [dbo].[t4a_definition_basis]
(
[t4_box] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[database_column] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[operator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[t4a_footnote_code] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[calendar_year] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t4a_definition_basis] ADD CONSTRAINT [pk_t4a_definition_basis] PRIMARY KEY CLUSTERED  ([calendar_year], [t4_box], [document], [document_type], [payer]) ON [PRIMARY]
GO
