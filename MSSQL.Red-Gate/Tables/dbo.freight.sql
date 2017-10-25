CREATE TABLE [dbo].[freight]
(
[freight] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[freight_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[freight] ADD CONSTRAINT [pk_freight] PRIMARY KEY CLUSTERED  ([freight]) ON [PRIMARY]
GO
