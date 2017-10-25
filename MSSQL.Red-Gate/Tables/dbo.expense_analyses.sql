CREATE TABLE [dbo].[expense_analyses]
(
[expense_analysis] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[expense_analysis_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[expense_analyses] ADD CONSTRAINT [pk_expense_analyses] PRIMARY KEY CLUSTERED  ([expense_analysis]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
