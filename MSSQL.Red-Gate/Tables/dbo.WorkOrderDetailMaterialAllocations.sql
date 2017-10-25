CREATE TABLE [dbo].[WorkOrderDetailMaterialAllocations]
(
[WorkOrderNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkOrderDetailLine] [float] NOT NULL CONSTRAINT [DF__WorkOrder__WorkO__666BEDB4] DEFAULT ((0)),
[WorkOrderDetailBillOfMaterialLine] [float] NOT NULL CONSTRAINT [DF__WorkOrder__WorkO__676011ED] DEFAULT ((0)),
[AllocationDT] [datetime] NOT NULL CONSTRAINT [DF__WorkOrder__Alloc__68543626] DEFAULT (getdate()),
[AllocationEndDT] [datetime] NULL,
[Serial] [int] NOT NULL,
[Status] [int] NOT NULL CONSTRAINT [DF__WorkOrder__Statu__69485A5F] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__WorkOrderD__Type__6A3C7E98] DEFAULT ((0)),
[QtyOriginal] [numeric] (20, 6) NOT NULL,
[QtyBegin] [numeric] (20, 6) NOT NULL,
[QtyIssued] [numeric] (20, 6) NULL,
[QtyEnd] [numeric] (20, 6) NULL,
[QtyEstimatedEnd] [numeric] (20, 6) NULL,
[QtyOverage] [numeric] (20, 6) NULL,
[QtyPer] [numeric] (20, 6) NULL,
[ChangeReason] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllowablePercentOverage] [numeric] (10, 6) NULL CONSTRAINT [DF__WorkOrder__Allow__6B30A2D1] DEFAULT ((0)),
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__WorkOrder__RowCr__6C24C70A] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__WorkOrder__RowCr__6D18EB43] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__WorkOrder__RowMo__6E0D0F7C] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__WorkOrder__RowMo__6F0133B5] DEFAULT (suser_name())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create trigger [dbo].[trWorkOrderDetailMaterialAllocations_d] on [dbo].[WorkOrderDetailMaterialAllocations] instead of delete
as
/*	Don't allow deletes.  */
update
	dbo.WorkOrderDetailMaterialAllocations
set
	Status = dbo.udf_StatusValue('dbo.WorkOrderDetailMaterialAllocations', 'Deleted')
,	RowModifiedDT = getdate()
,	RowModifiedUser = suser_name()
from
	dbo.WorkOrderDetailMaterialAllocations wodma
	join deleted d on
		wodma.RowID = d.RowID
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trWorkOrderDetailMaterialAllocations_u] on [dbo].[WorkOrderDetailMaterialAllocations] for update
as
/*	Record modification user and date.  */
if	not update(RowModifiedDT)
	and
		not update(RowModifiedUser) begin
	update
		dbo.WorkOrderDetailMaterialAllocations
	set
		RowModifiedDT = getdate()
	,	RowModifiedUser = suser_name()
	from
		dbo.WorkOrderDetailMaterialAllocations wodma
		join inserted i on
			wodma.RowID = i.RowID
end
GO
ALTER TABLE [dbo].[WorkOrderDetailMaterialAllocations] ADD CONSTRAINT [PK__WorkOrderDetailM__6483A542] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderDetailMaterialAllocations] ADD CONSTRAINT [UQ__WorkOrderDetailM__6577C97B] UNIQUE NONCLUSTERED  ([WorkOrderNumber], [WorkOrderDetailLine], [WorkOrderDetailBillOfMaterialLine], [AllocationDT], [Serial]) ON [PRIMARY]
GO
