CREATE TABLE [dbo].[ap_check_selection_identifiers]
(
[check_selection_identifier] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pay_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_vendor] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buy_unit] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_alias] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[latest_due_date] [datetime] NULL,
[latest_discount_date] [datetime] NULL,
[earliest_discount_date] [datetime] NULL,
[check_selection_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[direct_deposit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor_class] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_class] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ap_check_selection_identifiers] ADD CONSTRAINT [pk_ap_check_selection_identifiers] PRIMARY KEY CLUSTERED  ([check_selection_identifier]) ON [PRIMARY]
GO
