CREATE TABLE [dbo].[req_bids]
(
[requisition] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[vendor_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[buy_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bid_send_date] [datetime] NULL,
[bid_received_date] [datetime] NULL,
[bid_amount] [decimal] (18, 6) NULL,
[number_of_days_to_deliver] [int] NULL,
[bid_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[award_reason] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[req_bids] ADD CONSTRAINT [pk_req_bids] PRIMARY KEY CLUSTERED  ([requisition], [vendor_name]) ON [PRIMARY]
GO
