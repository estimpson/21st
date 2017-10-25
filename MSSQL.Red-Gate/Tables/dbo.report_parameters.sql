CREATE TABLE [dbo].[report_parameters]
(
[report_id] [int] NOT NULL,
[report_parameter_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[database_table_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[column_type] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[required] [bit] NULL,
[single_value] [bit] NULL,
[display_order] [smallint] NULL,
[format_string] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[compare_operator] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[join_operator] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[report_parameters] ADD CONSTRAINT [pk_report_parameters] PRIMARY KEY CLUSTERED  ([report_id], [report_parameter_name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[report_parameters] ADD CONSTRAINT [FK_report_parameters_reports] FOREIGN KEY ([report_id]) REFERENCES [dbo].[reports] ([report_id]) ON DELETE CASCADE ON UPDATE CASCADE
GO
