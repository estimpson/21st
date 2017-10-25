CREATE TABLE [dbo].[pos_security_ids]
(
[pos_security_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pos_security_id_first_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pos_security_id_last_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pos_security_ids] ADD CONSTRAINT [pk_pos_security_ids] PRIMARY KEY CLUSTERED  ([pos_security_id]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
