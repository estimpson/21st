CREATE TABLE [dbo].[py_check_sort_temporary]
(
[sort1] [varchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sort2] [varchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sort3] [varchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sort4] [varchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employee] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[voucher] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_amount] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [py_check_sort] ON [dbo].[py_check_sort_temporary] ([sort1], [sort2], [sort3], [sort4], [employee], [voucher], [check_amount]) ON [PRIMARY]
GO
