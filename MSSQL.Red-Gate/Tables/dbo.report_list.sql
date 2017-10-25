CREATE TABLE [dbo].[report_list]
(
[report] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[report_list] ADD CONSTRAINT [PK__report_list__32F66B4F] PRIMARY KEY CLUSTERED  ([report]) ON [PRIMARY]
GO
