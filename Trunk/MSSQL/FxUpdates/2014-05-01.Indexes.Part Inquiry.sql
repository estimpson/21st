/*
Missing Index Details from SQLQuery3.sql - fxarmada-sql01\FX.FxArmada (sa (62))
The Query Processor estimates that implementing the following index could improve the query cost by 74.3132%.
*/

/*
USE [FxArmada]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [dbo].[object] ([type],[status])
INCLUDE ([part],[std_quantity])
GO
*/
CREATE NONCLUSTERED INDEX ix_object_1
ON [dbo].[object] ([type],[status], [part])
INCLUDE ([std_quantity])
go

create index ix_part_packaging_1
on dbo.part_packaging (part, quantity) include (code)
go
