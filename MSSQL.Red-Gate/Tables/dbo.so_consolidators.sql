CREATE TABLE [dbo].[so_consolidators]
(
[consolidator] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[consolidator_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[so_consolidators] ADD CONSTRAINT [pk_so_consolidators] PRIMARY KEY CLUSTERED  ([consolidator]) ON [PRIMARY]
GO
