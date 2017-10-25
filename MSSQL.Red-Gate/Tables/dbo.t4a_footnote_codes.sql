CREATE TABLE [dbo].[t4a_footnote_codes]
(
[footnote_code] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[footnote_code_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[t4a_text] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t4a_footnote_codes] ADD CONSTRAINT [pk_t4a_footnote_codes] PRIMARY KEY CLUSTERED  ([footnote_code]) ON [PRIMARY]
GO
