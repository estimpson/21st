CREATE TABLE [dbo].[bank_statements]
(
[bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[statement_date] [datetime] NOT NULL,
[ending_balance] [decimal] (18, 6) NOT NULL,
[changed_date] [datetime] NOT NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bank_statements] ADD CONSTRAINT [pk_bank_statements] PRIMARY KEY CLUSTERED  ([bank_alias], [statement_date]) ON [PRIMARY]
GO
