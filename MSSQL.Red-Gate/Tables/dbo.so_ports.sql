CREATE TABLE [dbo].[so_ports]
(
[port] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[port_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[so_ports] ADD CONSTRAINT [pk_so_ports] PRIMARY KEY CLUSTERED  ([port]) ON [PRIMARY]
GO
