CREATE TABLE [dbo].[cash_flow_sections]
(
[cash_flow_section] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cash_flow_section_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cash_flow_sections] ADD CONSTRAINT [pk_cash_flow_sections] PRIMARY KEY NONCLUSTERED  ([cash_flow_section]) ON [PRIMARY]
GO
