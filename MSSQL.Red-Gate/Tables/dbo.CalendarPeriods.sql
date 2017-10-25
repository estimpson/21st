CREATE TABLE [dbo].[CalendarPeriods]
(
[CalendarName] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BeginDT] [datetime] NOT NULL,
[EndDT] [datetime] NOT NULL,
[Precedence] [float] NOT NULL CONSTRAINT [DF__CalendarP__Prece__15B0EC82] DEFAULT ((0)),
[Status] [int] NOT NULL,
[Type] [int] NOT NULL,
[PeriodDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CalendarRowID] [int] NOT NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreatedDT] [datetime] NOT NULL CONSTRAINT [DF__CalendarP__RowCr__179934F4] DEFAULT (getdate()),
[RowCreatedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__CalendarP__RowCr__188D592D] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CalendarPeriods] ADD CONSTRAINT [FK__CalendarP__Calen__14BCC849] FOREIGN KEY ([CalendarName]) REFERENCES [dbo].[Calendars] ([CalendarName])
GO
ALTER TABLE [dbo].[CalendarPeriods] ADD CONSTRAINT [FK__CalendarP__Calen__16A510BB] FOREIGN KEY ([CalendarRowID]) REFERENCES [dbo].[Calendars] ([RowID])
GO
