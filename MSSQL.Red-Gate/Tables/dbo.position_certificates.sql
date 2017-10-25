CREATE TABLE [dbo].[position_certificates]
(
[position] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[certificate] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[minimum_rating] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[position_certificates] ADD CONSTRAINT [pk_position_certificates] PRIMARY KEY CLUSTERED  ([position], [certificate]) ON [PRIMARY]
GO
