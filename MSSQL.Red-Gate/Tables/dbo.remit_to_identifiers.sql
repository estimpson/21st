CREATE TABLE [dbo].[remit_to_identifiers]
(
[remit_to] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[remit_to_identifiers] ADD CONSTRAINT [pk_remit_to_identifiers] PRIMARY KEY CLUSTERED  ([remit_to]) ON [PRIMARY]
GO
