CREATE TABLE [dbo].[t1099_summary_temporary]
(
[year_1099] [int] NOT NULL,
[company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pay_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[code_1099] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[paid_amount] [decimal] (18, 6) NOT NULL,
[vendor_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor_tax_id] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t1099_summary_temporary] ADD CONSTRAINT [pk_t1099_summary_temporary] PRIMARY KEY CLUSTERED  ([year_1099], [company], [pay_vendor], [code_1099]) ON [PRIMARY]
GO
