CREATE TABLE [dbo].[dd_foreign_banks]
(
[dd_foreign_bank] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dd_foreign_bank_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dd_foreign_bank_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dd_foreign_banks] ADD CONSTRAINT [pk_dd_foreign_banks] PRIMARY KEY CLUSTERED  ([dd_foreign_bank]) ON [PRIMARY]
GO
