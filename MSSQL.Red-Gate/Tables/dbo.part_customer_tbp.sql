CREATE TABLE [dbo].[part_customer_tbp]
(
[customer] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[effect_date] [datetime] NOT NULL,
[price] [numeric] (20, 6) NULL CONSTRAINT [DF__part_cust__price__50BBD860] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[part_customer_tbp] ADD CONSTRAINT [PK__part_customer_tb__4FC7B427] PRIMARY KEY CLUSTERED  ([customer], [part], [effect_date]) ON [PRIMARY]
GO
