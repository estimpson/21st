CREATE TABLE [dbo].[requisition_project_number]
(
[project_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[requisition_project_number] ADD CONSTRAINT [PK__requisition_proj__5614BF03] PRIMARY KEY CLUSTERED  ([project_number]) ON [PRIMARY]
GO
