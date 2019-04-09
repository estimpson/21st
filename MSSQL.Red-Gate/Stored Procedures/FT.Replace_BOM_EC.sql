SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [FT].[Replace_BOM_EC] (@oldpart VARCHAR(25), @newpart CHAR(25))

AS BEGIN

--EXEC   FT.Replace_BOM_EC '19501' , '10384LDRS'


DECLARE @datetimeDT DATETIME =  GETDATE()
				--,@oldPart VARCHAR(25) = '19501XXXXXXXXXYYY'
				--,@newPart VARCHAR(25) = '10384LDRS'
				,@Note VARCHAR(255) 
				
				SELECT @Note = (SELECT 'Created by procedure FT.Replace_BOM_EC  ' + CONVERT(VARCHAR(25),@datetimeDT ) )


--Disable Triggers on bill_of_material_ec

ALTER TABLE dbo.bill_of_material_ec
DISABLE TRIGGER ALL ;

--Update existing Bill_of_material_ec rows with end_datetime

UPDATE dbo.bill_of_material_ec
SET end_datetime = @datetimeDT
WHERE end_datetime IS NULL AND
				part = @oldPart


--Insert new bill_of_material_ec rows

INSERT INTO [dbo].[bill_of_material_ec]
           ([LastUser]
           ,[LastDT]
           ,[parent_part]
           ,[part]
           ,[start_datetime]
           ,[end_datetime]
           ,[type]
           ,[quantity]
           ,[unit_measure]
           ,[reference_no]
           ,[std_qty]
           ,[scrap_factor]
           ,[engineering_level]
           ,[operator]
           ,[substitute_part]
           ,[date_changed]
           ,[note]) 
SELECT [LastUser] = 'sa'
           ,[LastDT] = @datetimeDT
           ,[parent_part] =  parent_part
           ,[part] = @newPart
           ,[start_datetime] = @datetimeDT
           ,[end_datetime] = NULL
           ,[type] = 'M'
           ,[quantity] = quantity
           ,[unit_measure] = unit_measure
           ,[reference_no] = reference_no
           ,[std_qty] = std_qty
           ,[scrap_factor] =  scrap_factor
           ,[engineering_level] = engineering_level
           ,[operator] = operator
           ,[substitute_part] =  substitute_part
           ,[date_changed] =  @datetimeDT
           ,[note] = @Note

	 FROM dbo.bill_of_material_ec
	 WHERE end_datetime = @datetimeDT 
		AND		part = @oldPart

--Call XRT refresh Proc

-- The is done in the job MES Scheduling

--Update Exisiting workorders

--????????????????????

ALTER TABLE dbo.bill_of_material_ec
ENABLE TRIGGER ALL ;

END

	 
	 
GO
