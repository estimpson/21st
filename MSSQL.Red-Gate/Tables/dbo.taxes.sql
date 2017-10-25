CREATE TABLE [dbo].[taxes]
(
[tax] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tax_authority] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_percent] [decimal] (12, 6) NULL,
[include_tax] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[capitalize_tax] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dr_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cr_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contract_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contract_account_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[costrevenue_type_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[taxes] ADD CONSTRAINT [pk_taxes] PRIMARY KEY CLUSTERED  ([tax]) ON [PRIMARY]
GO
