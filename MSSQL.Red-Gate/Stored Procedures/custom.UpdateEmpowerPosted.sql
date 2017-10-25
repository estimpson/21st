SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [custom].[UpdateEmpowerPosted] @invoiceNumber int, @Posted varchar(1)
as
Begin
Update 
	shipper
Set		
	posted = @Posted
Where
	id = @InvoiceNumber
End
GO
