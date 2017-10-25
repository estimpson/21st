CREATE TABLE [dbo].[deduction_rate_basis]
(
[deduction_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[basis_document] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[basis_document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[basis_operator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[deduction_rate_basis] ADD CONSTRAINT [pk_deduction_rate_basis] PRIMARY KEY CLUSTERED  ([deduction_type], [basis_document], [basis_document_type]) ON [PRIMARY]
GO
