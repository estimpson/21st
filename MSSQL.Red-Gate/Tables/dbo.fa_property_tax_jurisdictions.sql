CREATE TABLE [dbo].[fa_property_tax_jurisdictions]
(
[property_tax_jurisdiction] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[property_tax_jurisdiction_nam] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_filing_month] [smallint] NULL,
[tax_filing_year] [smallint] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fa_property_tax_jurisdictions] ADD CONSTRAINT [pk_fa_property_tax_jurisdictions] PRIMARY KEY CLUSTERED  ([property_tax_jurisdiction]) ON [PRIMARY]
GO
