CREATE TABLE [dbo].[gl_tran_type]
(
[code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[gl_tran_type] ADD CONSTRAINT [PK__gl_tran_type__174E50DA] PRIMARY KEY CLUSTERED  ([code]) ON [PRIMARY]
GO
