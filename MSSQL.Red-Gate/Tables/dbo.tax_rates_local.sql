CREATE TABLE [dbo].[tax_rates_local]
(
[tax_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[breakpoint] [decimal] (18, 6) NOT NULL,
[base] [decimal] (18, 6) NULL,
[tax_percent] [decimal] (12, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tax_rates_local] ADD CONSTRAINT [pk_tax_rates_local] PRIMARY KEY CLUSTERED  ([tax_type], [breakpoint]) ON [PRIMARY]
GO
