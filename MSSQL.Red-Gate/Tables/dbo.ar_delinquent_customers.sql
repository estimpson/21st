CREATE TABLE [dbo].[ar_delinquent_customers]
(
[collection_agent] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[as_of_date] [datetime] NULL,
[delinquent_amount] [decimal] (18, 6) NULL,
[number_of_invoices] [int] NULL,
[max_past_due_days] [int] NULL,
[ave_past_due_days] [int] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ar_delinquent_customers] ADD CONSTRAINT [pk_ar_delinquent_customers] PRIMARY KEY CLUSTERED  ([collection_agent], [customer]) ON [PRIMARY]
GO
