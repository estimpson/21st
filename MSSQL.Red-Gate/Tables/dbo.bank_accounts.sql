CREATE TABLE [dbo].[bank_accounts]
(
[bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bank_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_account_number] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[direct_deposit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[direct_deposit_origin_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_check_number] [int] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[routing_number] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deposit_identifier_format] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_direct_deposit_number] [int] NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[direct_deposit_debit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bank_accounts] ADD CONSTRAINT [pk_bank_accounts] PRIMARY KEY CLUSTERED  ([bank_alias]) ON [PRIMARY]
GO
