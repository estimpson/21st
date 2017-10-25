CREATE TABLE [dbo].[terms]
(
[terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[terms_description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[net_days] [smallint] NULL,
[disc_percent] [decimal] (12, 6) NULL,
[disc_days] [smallint] NULL,
[eom_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eom_cutoff] [smallint] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[terms] ADD CONSTRAINT [pk_terms] PRIMARY KEY CLUSTERED  ([terms]) ON [PRIMARY]
GO
