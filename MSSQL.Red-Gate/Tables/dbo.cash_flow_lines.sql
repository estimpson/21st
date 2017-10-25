CREATE TABLE [dbo].[cash_flow_lines]
(
[cash_flow_section] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cash_flow_line] [smallint] NOT NULL,
[cash_flow_line_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reverse_sign] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cash_flow_lines] ADD CONSTRAINT [pk_cash_flow_lines] PRIMARY KEY NONCLUSTERED  ([cash_flow_section], [cash_flow_line]) ON [PRIMARY]
GO
