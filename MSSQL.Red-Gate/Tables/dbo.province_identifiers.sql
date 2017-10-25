CREATE TABLE [dbo].[province_identifiers]
(
[province_id] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[province_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[province_identifiers] ADD CONSTRAINT [pk_province_identifiers] PRIMARY KEY CLUSTERED  ([province_id]) ON [PRIMARY]
GO
