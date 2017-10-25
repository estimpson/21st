CREATE TABLE [dbo].[state_identifiers]
(
[state_id] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[state_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state_code] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[state_identifiers] ADD CONSTRAINT [pk_state_identifiers] PRIMARY KEY CLUSTERED  ([state_id]) ON [PRIMARY]
GO
