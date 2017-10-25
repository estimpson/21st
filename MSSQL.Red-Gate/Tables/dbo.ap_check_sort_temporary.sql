CREATE TABLE [dbo].[ap_check_sort_temporary]
(
[sort1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sort2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sort3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sort4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id_number] [int] NULL,
[check_amount] [decimal] (18, 6) NULL,
[number_of_stubs] [smallint] NULL,
[check_selection_identifier] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_alias] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_address_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_address_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_address_3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_state] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_postal_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_vendor_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_vendor_name_2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
