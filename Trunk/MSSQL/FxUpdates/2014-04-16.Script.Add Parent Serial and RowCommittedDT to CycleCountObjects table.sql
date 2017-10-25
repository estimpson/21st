/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.InventoryControl_CycleCountObjects
	DROP CONSTRAINT UQ__InventoryControl__60DDFCE7
GO
ALTER TABLE dbo.InventoryControl_CycleCountHeaders SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.InventoryControl_CycleCountObjects
	DROP CONSTRAINT DF__Inventory__Statu__63BA6992
GO
ALTER TABLE dbo.InventoryControl_CycleCountObjects
	DROP CONSTRAINT DF__InventoryC__Type__64AE8DCB
GO
ALTER TABLE dbo.InventoryControl_CycleCountObjects
	DROP CONSTRAINT DF__Inventory__RowCr__65A2B204
GO
ALTER TABLE dbo.InventoryControl_CycleCountObjects
	DROP CONSTRAINT DF__Inventory__RowCr__6696D63D
GO
ALTER TABLE dbo.InventoryControl_CycleCountObjects
	DROP CONSTRAINT DF__Inventory__RowMo__678AFA76
GO
ALTER TABLE dbo.InventoryControl_CycleCountObjects
	DROP CONSTRAINT DF__Inventory__RowMo__687F1EAF
GO
CREATE TABLE dbo.Tmp_InventoryControl_CycleCountObjects
	(
	CycleCountNumber varchar(50) NULL,
	Line float(53) NULL,
	Serial int NULL,
	ParentSerial int NULL,
	Status int NOT NULL,
	Type int NOT NULL,
	Part varchar(25) NOT NULL,
	OriginalQuantity numeric(20, 6) NOT NULL,
	CorrectedQuantity numeric(20, 6) NULL,
	Unit char(2) NOT NULL,
	OriginalLocation varchar(10) NOT NULL,
	CorrectedLocation varchar(10) NULL,
	RowCommittedDT datetime NULL,
	RowID int NOT NULL IDENTITY (1, 1),
	RowCreateDT datetime NULL,
	RowCreateUser sysname NOT NULL,
	RowModifiedDT datetime NULL,
	RowModifiedUser sysname NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_InventoryControl_CycleCountObjects SET (LOCK_ESCALATION = TABLE)
GO
ALTER TABLE dbo.Tmp_InventoryControl_CycleCountObjects ADD CONSTRAINT
	DF__Inventory__Statu__0F3C2679 DEFAULT ((0)) FOR Status
GO
ALTER TABLE dbo.Tmp_InventoryControl_CycleCountObjects ADD CONSTRAINT
	DF__InventoryC__Type__10304AB2 DEFAULT ((0)) FOR Type
GO
ALTER TABLE dbo.Tmp_InventoryControl_CycleCountObjects ADD CONSTRAINT
	DF__Inventory__RowCr__11246EEB DEFAULT (getdate()) FOR RowCreateDT
GO
ALTER TABLE dbo.Tmp_InventoryControl_CycleCountObjects ADD CONSTRAINT
	DF__Inventory__RowCr__12189324 DEFAULT (suser_name()) FOR RowCreateUser
GO
ALTER TABLE dbo.Tmp_InventoryControl_CycleCountObjects ADD CONSTRAINT
	DF__Inventory__RowMo__130CB75D DEFAULT (getdate()) FOR RowModifiedDT
GO
ALTER TABLE dbo.Tmp_InventoryControl_CycleCountObjects ADD CONSTRAINT
	DF__Inventory__RowMo__1400DB96 DEFAULT (suser_name()) FOR RowModifiedUser
GO
SET IDENTITY_INSERT dbo.Tmp_InventoryControl_CycleCountObjects ON
GO
IF EXISTS(SELECT * FROM dbo.InventoryControl_CycleCountObjects)
	 EXEC('INSERT INTO dbo.Tmp_InventoryControl_CycleCountObjects (CycleCountNumber, Line, Serial, Status, Type, Part, OriginalQuantity, CorrectedQuantity, Unit, OriginalLocation, CorrectedLocation, RowID, RowCreateDT, RowCreateUser, RowModifiedDT, RowModifiedUser)
		SELECT CycleCountNumber, Line, Serial, Status, Type, Part, OriginalQuantity, CorrectedQuantity, Unit, OriginalLocation, CorrectedLocation, RowID, RowCreateDT, RowCreateUser, RowModifiedDT, RowModifiedUser FROM dbo.InventoryControl_CycleCountObjects WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_InventoryControl_CycleCountObjects OFF
GO
DROP TABLE dbo.InventoryControl_CycleCountObjects
GO
EXECUTE sp_rename N'dbo.Tmp_InventoryControl_CycleCountObjects', N'InventoryControl_CycleCountObjects', 'OBJECT' 
GO
ALTER TABLE dbo.InventoryControl_CycleCountObjects ADD CONSTRAINT
	PK__Inventor__FFEE745003F3CF9E PRIMARY KEY NONCLUSTERED 
	(
	RowID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.InventoryControl_CycleCountObjects ADD CONSTRAINT
	UQ__Inventor__530AB6685EDCCA23 UNIQUE CLUSTERED 
	(
	CycleCountNumber,
	Line
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.InventoryControl_CycleCountObjects ADD CONSTRAINT
	UQ__Inventor__1928C5A66210D6F3 UNIQUE NONCLUSTERED 
	(
	CycleCountNumber,
	Serial,
	RowCommittedDT
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.InventoryControl_CycleCountObjects ADD CONSTRAINT
	FK__Inventory__Cycle__0E480240 FOREIGN KEY
	(
	CycleCountNumber
	) REFERENCES dbo.InventoryControl_CycleCountHeaders
	(
	CycleCountNumber
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
go

update
	iccco
set	RowCommittedDT = iccch.CountEndDT
from
	dbo.InventoryControl_CycleCountObjects iccco
	join dbo.InventoryControl_CycleCountHeaders iccch
		on iccch.CycleCountNumber = iccco.CycleCountNumber
where
	iccch.CountEndDT is not null
go

select
	*
from
	dbo.InventoryControl_CycleCountObjects
go

