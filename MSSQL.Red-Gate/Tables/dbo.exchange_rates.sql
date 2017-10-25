CREATE TABLE [dbo].[exchange_rates]
(
[currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[effective_on_date] [datetime] NOT NULL,
[effective_off_date] [datetime] NULL,
[exchange_rate] [decimal] (12, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[exchange_rates] ADD CONSTRAINT [pk_exchange_rates] PRIMARY KEY CLUSTERED  ([currency], [effective_on_date]) ON [PRIMARY]
GO
