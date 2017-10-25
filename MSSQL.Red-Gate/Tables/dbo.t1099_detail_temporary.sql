CREATE TABLE [dbo].[t1099_detail_temporary]
(
[year_1099] [int] NOT NULL,
[company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pay_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pay_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[code_1099] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_number] [int] NULL,
[check_date] [datetime] NULL,
[paid_amount] [decimal] (18, 6) NULL,
[invoice_cm] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inv_cm_sort_line] [smallint] NULL,
[item_description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
