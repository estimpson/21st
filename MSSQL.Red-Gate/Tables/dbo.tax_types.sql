CREATE TABLE [dbo].[tax_types]
(
[tax_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tax_type_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_stub_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dr_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_calculation_source] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exemption_amount] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[security_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cost_account_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[w2_local] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[annualized_or_ytd] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tax_types] ADD CONSTRAINT [pk_tax_types] PRIMARY KEY CLUSTERED  ([tax_type]) ON [PRIMARY]
GO
