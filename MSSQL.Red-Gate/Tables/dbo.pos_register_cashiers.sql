CREATE TABLE [dbo].[pos_register_cashiers]
(
[pos_register] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pos_cashier] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pos_cashier_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pos_register_cashiers] ADD CONSTRAINT [pk_pos_register_cashiers] PRIMARY KEY CLUSTERED  ([pos_register], [pos_cashier]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
