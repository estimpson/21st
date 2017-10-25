CREATE TABLE [dbo].[RegionsUS]
(
[StateCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StateName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [int] NULL CONSTRAINT [DF__RegionsUS__Activ__5D6C935F] DEFAULT ((1))
) ON [PRIMARY]
GO
