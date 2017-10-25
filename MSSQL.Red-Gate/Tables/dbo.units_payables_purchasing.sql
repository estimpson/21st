CREATE TABLE [dbo].[units_payables_purchasing]
(
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_entry_frequency] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[units_payables_purchasing] ADD CONSTRAINT [pk_units_payables_purchasing] PRIMARY KEY CLUSTERED  ([unit]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
