CREATE TABLE [dbo].[termination_reasons]
(
[termination_reason] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[termination_reasons] ADD CONSTRAINT [pk_termination_reasons] PRIMARY KEY CLUSTERED  ([termination_reason]) ON [PRIMARY]
GO
