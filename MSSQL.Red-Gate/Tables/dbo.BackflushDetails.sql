CREATE TABLE [dbo].[BackflushDetails]
(
[BackflushNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Line] [float] NOT NULL CONSTRAINT [DF__BackflushD__Line__2AAC0968] DEFAULT ((0)),
[Status] [int] NOT NULL CONSTRAINT [DF__Backflush__Statu__2BA02DA1] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__BackflushD__Type__2C9451DA] DEFAULT ((0)),
[ChildPartSequence] [int] NOT NULL,
[ChildPartBOMLevel] [int] NOT NULL,
[BillOfMaterialID] [int] NULL,
[PartConsumed] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialConsumed] [int] NOT NULL,
[QtyAvailable] [numeric] (20, 6) NOT NULL,
[QtyRequired] [numeric] (20, 6) NOT NULL,
[QtyIssue] [numeric] (20, 6) NOT NULL,
[QtyOverage] [numeric] (20, 6) NULL,
[Notes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__Backflush__RowCr__2D887613] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Backflush__RowCr__2E7C9A4C] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__Backflush__RowMo__2F70BE85] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__Backflush__RowMo__3064E2BE] DEFAULT (suser_name())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create trigger [dbo].[trBackflushDetails_d] on [dbo].[BackflushDetails] instead of delete
as
/*	Don't allow deletes.  */
update
	dbo.BackflushDetails
set
	Status = dbo.udf_StatusValue('dbo.BackflushDetails', 'Deleted')
,	RowModifiedDT = getdate()
,	RowModifiedUser = suser_name()
from
	dbo.WorkOrderHeaders woh
	join deleted d on
		woh.RowID = d.RowID
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trBackflushDetails_u] on [dbo].[BackflushDetails] for update
as
/*	Record modification user and date.  */
if	not update(RowModifiedDT)
	and
		not update(RowModifiedUser) begin
	update
		dbo.BackflushDetails
	set
		RowModifiedDT = getdate()
	,	RowModifiedUser = suser_name()
	from
		dbo.BackflushDetails wod
		join inserted i on
			wod.RowID = i.RowID
end
GO
ALTER TABLE [dbo].[BackflushDetails] ADD CONSTRAINT [PK__BackflushDetails__27CF9CBD] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BackflushDetails] ADD CONSTRAINT [UQ__BackflushDetails__28C3C0F6] UNIQUE NONCLUSTERED  ([BackflushNumber], [Line]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_BackflushDetails_SerialConsumed] ON [dbo].[BackflushDetails] ([SerialConsumed], [BackflushNumber]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BackflushDetails] ADD CONSTRAINT [FK__Backflush__Backf__29B7E52F] FOREIGN KEY ([BackflushNumber]) REFERENCES [dbo].[BackflushHeaders] ([BackflushNumber])
GO
