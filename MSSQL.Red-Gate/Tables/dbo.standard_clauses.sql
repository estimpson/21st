CREATE TABLE [dbo].[standard_clauses]
(
[standard_clause] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[standard_clauses] ADD CONSTRAINT [pk_standard_clauses] PRIMARY KEY CLUSTERED  ([standard_clause]) ON [PRIMARY]
GO
