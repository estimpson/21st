CREATE TABLE [dbo].[ipeds_calculations]
(
[ipeds_calculation] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ipeds_date] [datetime] NULL,
[company] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ipeds_calculations] ADD CONSTRAINT [pk_ipeds_calculations] PRIMARY KEY CLUSTERED  ([ipeds_calculation]) ON [PRIMARY]
GO
