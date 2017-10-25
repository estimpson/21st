CREATE TABLE [dbo].[currencies]
(
[currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[currency_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[base_currency] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[currencies] ADD CONSTRAINT [pk_currencies] PRIMARY KEY CLUSTERED  ([currency]) ON [PRIMARY]
GO
