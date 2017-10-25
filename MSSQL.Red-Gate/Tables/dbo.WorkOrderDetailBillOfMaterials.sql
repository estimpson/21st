CREATE TABLE [dbo].[WorkOrderDetailBillOfMaterials]
(
[WorkOrderNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkOrderDetailLine] [float] NOT NULL CONSTRAINT [DF__WorkOrder__WorkO__4E2A4FCF] DEFAULT ((0)),
[Line] [float] NOT NULL CONSTRAINT [DF__WorkOrderD__Line__4F1E7408] DEFAULT ((0)),
[Status] [int] NOT NULL CONSTRAINT [DF__WorkOrder__Statu__50129841] DEFAULT ((0)),
[Type] [int] NOT NULL CONSTRAINT [DF__WorkOrderD__Type__5106BC7A] DEFAULT ((0)),
[ChildPart] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChildPartSequence] [int] NOT NULL,
[ChildPartBOMLevel] [int] NOT NULL,
[BillOfMaterialID] [int] NULL,
[Suffix] [int] NULL,
[QtyPer] [numeric] (20, 6) NULL,
[XQty] [numeric] (20, 6) NOT NULL,
[XScrap] [numeric] (20, 6) NOT NULL CONSTRAINT [DF__WorkOrder__XScra__52EF04EC] DEFAULT ((0)),
[SubForRowID] [int] NULL,
[SubPercentage] [numeric] (20, 6) NULL,
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowCreateDT] [datetime] NULL CONSTRAINT [DF__WorkOrder__RowCr__54D74D5E] DEFAULT (getdate()),
[RowCreateUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__WorkOrder__RowCr__55CB7197] DEFAULT (suser_name()),
[RowModifiedDT] [datetime] NULL CONSTRAINT [DF__WorkOrder__RowMo__56BF95D0] DEFAULT (getdate()),
[RowModifiedUser] [sys].[sysname] NOT NULL CONSTRAINT [DF__WorkOrder__RowMo__57B3BA09] DEFAULT (suser_name())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE trigger [dbo].[trWorkOrderDetailBillOfMaterials_d] on [dbo].[WorkOrderDetailBillOfMaterials] instead of delete
as
/*	Don't allow deletes.  */
update
	dbo.WorkOrderDetailBillOfMaterials
set
	Line = coalesce
	(	(	select
				min(Line)
			from
				dbo.WorkOrderDetailBillOfMaterials
			where
				WorkOrderNumber = wodbom.WorkOrderNumber
				and WorkOrderDetailLine = wodbom.WorkOrderDetailLine
				and Line < 0
		) - 1
	,	-1
	)
,	Status = dbo.udf_StatusValue('dbo.WorkOrderDetailBillOfMaterials', 'Deleted')
,	RowModifiedDT = getdate()
,	RowModifiedUser = suser_name()
from
	dbo.WorkOrderDetailBillOfMaterials wodbom
	join deleted d on
		wodbom.RowID = d.RowID
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[trWorkOrderDetailBillOfMaterials_u] on [dbo].[WorkOrderDetailBillOfMaterials] for update
as
/*	Record modification user and date.  */
if	not update(RowModifiedDT)
	and
		not update(RowModifiedUser) begin
	update
		dbo.WorkOrderDetailBillOfMaterials
	set
		RowModifiedDT = getdate()
	,	RowModifiedUser = suser_name()
	from
		dbo.WorkOrderDetailBillOfMaterials wodbom
		join inserted i on
			wodbom.RowID = i.RowID
end
GO
ALTER TABLE [dbo].[WorkOrderDetailBillOfMaterials] ADD CONSTRAINT [PK__WorkOrderDetailB__4C42075D] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderDetailBillOfMaterials] ADD CONSTRAINT [UQ__WorkOrderDetailB__4D362B96] UNIQUE NONCLUSTERED  ([WorkOrderNumber], [WorkOrderDetailLine], [Line]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkOrderDetailBillOfMaterials] ADD CONSTRAINT [FK__WorkOrder__BillO__51FAE0B3] FOREIGN KEY ([BillOfMaterialID]) REFERENCES [dbo].[bill_of_material_ec] ([ID]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[WorkOrderDetailBillOfMaterials] ADD CONSTRAINT [FK__WorkOrder__SubFo__53E32925] FOREIGN KEY ([SubForRowID]) REFERENCES [dbo].[WorkOrderDetailBillOfMaterials] ([RowID])
GO
