SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[usp_ObtainLabelDataForReceipt]
(	@Serial int)
as
Declare	@MaxReceiptDate Datetime

Select	@MaxReceiptDate = max(date_stamp)
From	audit_trail
Where	type in ('R','A') and
	serial = @serial

Select		COALESCE(O.serial, AT.serial) Serial,
		Part.part Part,
		COALESCE(O.serial, AT.serial) Description
		
From		Audit_trail AT
Left join	object O on AT.Serial = O.serial
Join part	on AT.part = Part.part
Where		AT.Date_Stamp = @MaxReceiptDate

GO
