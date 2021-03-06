CREATE TABLE [dbo].[Calendars]
(
[CalendarName] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [int] NOT NULL,
[Type] [int] NOT NULL,
[CalendarDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreatedDT] [datetime] NOT NULL CONSTRAINT [DF__Calendars__RowCr__11E05B9E] DEFAULT (getdate()),
[RowCreatedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Calendars__RowCr__12D47FD7] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Calendars] ADD CONSTRAINT [PK__Calendars__0FF8132C] PRIMARY KEY CLUSTERED  ([CalendarName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Calendars] ADD CONSTRAINT [UQ__Calendars__10EC3765] UNIQUE NONCLUSTERED  ([RowID]) ON [PRIMARY]
GO
