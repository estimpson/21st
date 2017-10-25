CREATE TABLE [dbo].[t1099_totals_temporary]
(
[year_1099] [int] NOT NULL,
[company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pay_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[vendor_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor_name_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor_address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor_tax_id] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount_1] [decimal] (18, 6) NULL,
[amount_2] [decimal] (18, 6) NULL,
[amount_3] [decimal] (18, 6) NULL,
[amount_4] [decimal] (18, 6) NULL,
[amount_5] [decimal] (18, 6) NULL,
[amount_6] [decimal] (18, 6) NULL,
[amount_7] [decimal] (18, 6) NULL,
[amount_8] [decimal] (18, 6) NULL,
[amount_9] [decimal] (18, 6) NULL,
[amount_10] [decimal] (18, 6) NULL,
[amount_11] [decimal] (18, 6) NULL,
[amount_12] [decimal] (18, 6) NULL,
[company_address_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t1099_totals_temporary] ADD CONSTRAINT [pk_t1099_totals_temporary] PRIMARY KEY CLUSTERED  ([year_1099], [company], [pay_vendor]) ON [PRIMARY]
GO
