CREATE TABLE [dbo].[ipeds_primary_functions]
(
[primary_function] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[primary_function_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primary_function_sort] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ipeds_primary_functions] ADD CONSTRAINT [pk_ipeds_primary_functions] PRIMARY KEY CLUSTERED  ([primary_function]) ON [PRIMARY]
GO
