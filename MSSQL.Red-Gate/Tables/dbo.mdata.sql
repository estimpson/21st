CREATE TABLE [dbo].[mdata]
(
[pmcode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mcode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[switch] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__mdata__switch__703483B9] DEFAULT ('N'),
[display] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__mdata__display__7128A7F2] DEFAULT ('N'),
[menuName] [sys].[sysname] NULL,
[menuIcon] [sys].[sysname] NULL,
[objectName] [sys].[sysname] NULL,
[objectType] [sys].[sysname] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mdata] ADD CONSTRAINT [PK__mdata__6F405F80] PRIMARY KEY CLUSTERED  ([mcode]) ON [PRIMARY]
GO
