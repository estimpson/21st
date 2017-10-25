SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[usp_PriceAdmin_ActivateBlanketPriceChanges1]
(	@UserCode varchar(5) = null,
	@UserName varchar(40) = 'SQL Manager',
	@TranDT datetime = null out,
	@Result int = 0 out)
as

set nocount on
set	@Result = 999999

--- <Error Handling>
declare	
	@CallProcName sysname,
	@TableName sysname,
	@ProcName sysname,
	@ProcReturn int,
	@ProcResult int,
	@Error int,
	@RowCount int
	
set	@ProcName = user_name(objectproperty(@@procid, 'OwnerId')) + '.' + object_name(@@procid)  -- e.g. dbo.usp_Test
--- </Error Handling>

--- <Tran Required=Yes AutoCreate=Yes TranDTParm=Yes>
declare	@TranCount smallint

set	@TranCount = @@TranCount
if	@TranCount = 0 begin
	begin tran @ProcName
end
save tran @ProcName
set	@TranDT = coalesce(@TranDT, GetDate())
--- </Tran>


-- Lock table
delete	BlanketPriceChanges
from	BlanketPriceChanges with (tablockx)
where	1 = 0


declare	@ActivatedDate datetime
set		@ActivatedDate = getdate()



-- Insert data for table that is about to be updated into the log table
set		@TableName = 'dbo.BlanketPriceActivatedLog'
insert	
		BlanketPriceActivatedLog
		(	TableAffected,
			Part,
			Customer,
			PreviousBlanketPrice,
			NewBlanketPrice,
			UserCode,
			UserName,
			ActivatedDate)
select
		TableAffected = 'part_customer',
		Part = part_customer.part,
		Customer = part_customer.customer,
		PreviousBlanketPrice = part_customer.blanket_price,
		NewBlanketPrice = bpc.BlanketPrice,
		UserCode = @UserCode,
		UserName = @UserName,
		ActivatedDate = @ActivatedDate
from	
		part_customer join 
		BlanketPriceChanges bpc on 
		bpc.Part = part_customer.part and
		bpc.Customer = part_customer.customer
where	
		bpc.EffectiveDate < getdate() and bpc.Activated = 0

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end

-- Update part_customer 
set		@TableName = 'dbo.part_customer'
update	
		part_customer
set		
		part_customer.blanket_price = bpc.BlanketPrice
from	
		part_customer join 
		BlanketPriceChanges bpc on 
		bpc.Part = part_customer.part and
		bpc.Customer = part_customer.customer
where	
		bpc.EffectiveDate < getdate() and bpc.Activated = 0

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end



-- Insert data for table that is about to be updated into the log table
set		@TableName = 'dbo.BlanketPriceActivatedLog'
insert	
		BlanketPriceActivatedLog
		(	TableAffected,
			Part,
			PreviousBlanketPrice,
			NewBlanketPrice,
			UserCode,
			UserName,
			ActivatedDate)
select
		TableAffected = 'part_standard',
		Part = part_standard.Part,
		PreviousBlanketPrice = part_standard.price,
		NewBlanketPrice = bpc.BlanketPrice,
		UserCode = @UserCode,
		UserName = @UserName,
		ActivatedDate = @ActivatedDate
from
		part_standard join
		BlanketPriceChanges bpc on
		bpc.Part = part_standard.part
where	
		bpc.EffectiveDate < getdate() and bpc.Activated = 0

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end

-- Update part_standard
set		@TableName = 'dbo.part_standard'
update	
		part_standard
set	
		part_standard.price = bpc.BlanketPrice
from
		part_standard join
		BlanketPriceChanges bpc on
		bpc.Part = part_standard.part
where	
		bpc.EffectiveDate < getdate() and bpc.Activated = 0

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end



-- Insert data for table that is about to be updated into the log table
set		@TableName = 'dbo.BlanketPriceActivatedLog'
insert	
		BlanketPriceActivatedLog
		(	TableAffected,
			Part,
			Customer,
			OrderNo,
			PreviousBlanketPrice,
			NewBlanketPrice,
			UserCode,
			UserName,
			ActivatedDate)
select
		TableAffected = 'order_header',
		Part = order_header.blanket_part,
		Customer = order_header.customer,
		OrderNo = order_header.order_no,
		PreviousBlanketPrice = order_header.price,
		NewBlanketPrice = bpc.BlanketPrice,
		UserCode = @UserCode,
		UserName = @UserName,
		ActivatedDate = @ActivatedDate
from	
		order_header join
		BlanketPriceChanges bpc on 
		bpc.Part = order_header.blanket_part and
		bpc.Customer = order_header.customer
where
		bpc.EffectiveDate < getdate() and bpc.Activated = 0

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end

-- Update order_header
set		@TableName = 'dbo.order_header'
update	
		order_header
set		
		order_header.price = bpc.BlanketPrice
from	
		order_header join
		BlanketPriceChanges bpc on 
		bpc.Part = order_header.blanket_part and
		bpc.Customer = order_header.customer
where
		bpc.EffectiveDate < getdate() and bpc.Activated = 0
		
select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end	



-- Insert data for table that is about to be updated into the log table
set		@TableName = 'dbo.BlanketPriceActivatedLog'
insert	
		BlanketPriceActivatedLog
		(	TableAffected,
			Part,
			Customer,
			OrderNo,
			TableRowID,
			PreviousBlanketPrice,
			NewBlanketPrice,
			UserCode,
			UserName,
			ActivatedDate)
select
		TableAffected = 'order_detail',
		Part = order_detail.part_number,
		Customer = order_header.customer,
		OrderNo = order_detail.order_no,
		TableRowID = order_detail.id,
		PreviousBlanketPrice = order_detail.price,
		NewBlanketPrice = bpc.BlanketPrice,
		UserCode = @UserCode,
		UserName = @UserName,
		ActivatedDate = @ActivatedDate
from
		order_detail join
		order_header on
		order_header.order_no = order_detail.order_no and
		order_header.blanket_part = order_detail.part_number join
		BlanketPriceChanges bpc	on
		bpc.Part = order_header.blanket_part and
		bpc.Customer = order_header.customer
where
		bpc.EffectiveDate < getdate() and bpc.Activated = 0

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end		

-- Update order_detail
set		@TableName = 'dbo.order_detail'
update	
		order_detail
set	
		order_detail.price = bpc.BlanketPrice
from
		order_detail join
		order_header on
		order_header.order_no = order_detail.order_no and
		order_header.blanket_part = order_detail.part_number join
		BlanketPriceChanges bpc	on
		bpc.Part = order_header.blanket_part and
		bpc.Customer = order_header.customer
where
		bpc.EffectiveDate < getdate() and bpc.Activated = 0
			
select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end		



-- Insert data for table that is about to be updated into the log table
set		@TableName = 'dbo.BlanketPriceActivatedLog'
insert	
		BlanketPriceActivatedLog
		(	TableAffected,
			Part,
			Customer,
			OrderNo,
			Shipper,
			PreviousBlanketPrice,
			NewBlanketPrice,
			UserCode,
			UserName,
			ActivatedDate)
select
		TableAffected = 'shipper_detail',
		Part = shipper_detail.part_original,
		Customer = order_header.customer,
		OrderNo = shipper_detail.order_no,
		Shipper = shipper_detail.shipper,
		PreviousBlanketPrice = shipper_detail.price,
		NewBlanketPrice = bpc.BlanketPrice,
		UserCode = @UserCode,
		UserName = @UserName,
		ActivatedDate = @ActivatedDate
from	
		shipper_detail join
		shipper on shipper_detail.shipper = shipper.id join
		order_header on
		order_header.order_no = shipper_detail.order_no and
		order_header.blanket_part = shipper_detail.part_original join
		BlanketPriceChanges bpc	on
		bpc.Part = order_header.blanket_part and
		bpc.Customer = order_header.customer
where 
		bpc.EffectiveDate < getdate() and bpc.Activated = 0
		and shipper.date_shipped is null
		and shipper.status in ('O', 'S')
		and shipper.type is null

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error inserting table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end		

-- Update shipper_detail
-- (where shipper has not been shipped, is not open or staged, and was not manually entered)
set		@TableName = 'dbo.shipper_detail'
update
		shipper_detail
set		
		shipper_detail.price = bpc.BlanketPrice
from	
		shipper_detail join
		shipper on shipper_detail.shipper = shipper.id join
		order_header on
		order_header.order_no = shipper_detail.order_no and
		order_header.blanket_part = shipper_detail.part_original join
		BlanketPriceChanges bpc	on
		bpc.Part = order_header.blanket_part and
		bpc.Customer = order_header.customer
where 
		bpc.EffectiveDate < getdate() and bpc.Activated = 0
		and shipper.date_shipped is null
		and shipper.status in ('O', 'S')
		and shipper.type is null

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end	



-- Update PartCustomerBlanketPriceChanges
set		@TableName = 'dbo.BlanketPriceChanges'
update	
		BlanketPriceChanges
set		
		Activated = 1,
		ActivatedDate = @ActivatedDate
where	
		EffectiveDate < getdate() and Activated = 0

select
	@Error = @@Error,
	@RowCount = @@Rowcount

if	@Error != 0 begin
	set	@Result = 999999
	RAISERROR ('Error updating table %s in procedure %s.  Error: %d', 16, 1, @TableName, @ProcName, @Error)
	rollback tran @ProcName
	return @Result
end


--<CloseTran Required=Yes AutoCreate=Yes>
if	@TranCount = 0 begin
	commit transaction @ProcName
end
--</CloseTran Required=Yes AutoCreate=Yes>

--	IV.	Return.
set	@Result = 0
return @Result
GO
