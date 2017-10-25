SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[msp_create_requisitionrel] AS
---------------------------------------------------------------------------------------
--	This procedure creates requisition based part kanban info ( min & max)
--
--	Modifications:	5 AUG 1999, Harish P. Gubbi	Original.
--
--	Parameters:	As of now nothing
--
--	Returns:	None
--
--	Process:
--	1.	Declare all the required local variables.
--	2.	Declare cursor for purchased finished, wip & raw parts
--	3.	Loop through each part
--	4.	Get summed qty from object & po releases for the current part
--	5.	Check part type for the currently fetched part
--	6	Arrive at the new work order quantity
-- 	6.5	Get Part Price from part_vendor_price_matrix			
--	7.	Create reqsuition header & detail records
-- 	8.	Get the next part
--	9.	Return
---------------------------------------------------------------------------------------

--	1.	Declare all the required local variables.
declare @part           varchar(25),
        @parttype      	char(1),
        @stdunit       	varchar(2),
	@onhand       	numeric(20,6),
        @minonhand	decimal(20,6),
        @maxonhand     	decimal(20,6),
        @requisitionqty	numeric(20,6),
        @poquantity	numeric(20,6),        
        @requisitionno  integer,
        @newqty    	numeric(20,6),
	@duedate       	datetime,
	@kanban         char(1),
	@vendor		varchar(10),
	@shiptodest	varchar(25),
	@shiptype	char(1),
	@shipvia	varchar(15),
	@terms		varchar(20),
	@rowid		integer,
	@desc		varchar(50),
	@account_code	varchar(50),
	@fob		varchar(10),
	@freighttype	varchar(15),
	@price		decimal(20,6)
	
select  @duedate=convert( datetime, (substring(convert(varchar(19), getdate()),1,11)))

--	2.	Declare cursor for Purchased finished, wip & raw parts
declare parts cursor for
	select  p.part,
		p.type,
		substring(p.name,1,50),
        	pi.standard_unit,
        	isnull(pol.min_onhand,0),
	       	isnull(pol.max_onhand,0),
        	pol.default_vendor,
         	pol.default_po_number,
         	v.kanban,
         	v.ship_via,
         	v.fob,
         	v.frieght_type,
         	v.terms,
		(select convert(numeric(20,6),isnull(sum(quantity),0))
			from object where object.part = p.part and object.status='A'),
		(select convert(numeric(20,6),isnull(sum(balance),0))
			from po_detail where po_detail.part_number = p.part)	
   	from 	part as p
   		join part_inventory as pi on pi.part = p.part
   		join part_online as pol on pol.part = p.part 
   		join vendor as v on v.code = pol.default_vendor
  	where 	p.class = 'P' and
  		pol.default_vendor is not null and 
  		(v.kanban = 'Y' or pol.kanban_required = 'Y') and pol.kanban_po_requisition = 'R'
	order by 1
	
--	3.	Loop through each part
open parts

fetch	parts
into	@part,
	@parttype,
	@desc,	
	@stdunit,
	@minonhand,
	@maxonhand,
	@vendor,
	@requisitionno,
	@kanban,
	@shipvia,
	@fob,
	@freighttype,
	@terms,
	@onhand,
	@poquantity
	
while ( @@fetch_status = 0 )
begin -- (1a)

--	get requisition qty for the part        
	select	@requisitionqty = isnull(sum(quantity),0)
	from	requisition_detail
		join requisition_header on requisition_header.requisition_number = requisition_detail.requisition_number
	where	requisition_detail.part_number = @part and 
		requisition_header.status <> '4' and 
		requisition_header.status <> '6'

--	6.	Arrive at the new requisition quantity
	if @onhand <= @minonhand
		if @poquantity < (@maxonhand - @onhand)
		begin 
	        	select @newqty= (@maxonhand - @onhand) - @poquantity
		        if @requisitionqty < @newqty
		        	select @newqty= @newqty - @requisitionqty
			else
	        		select @newqty= 0
	        end 	
		else
        		select @newqty= 0
	else
        	select @newqty= 0
-- 	6.5	Get Part Price from part_vendor_price_matrix			
	
	execute rsp_get_vendor_part_price  @part , @vendor , @newqty , @price 


--	7.	Create requisition detail records
	if @newqty > 0 		
	begin -- (2a)
	
		-- get next requisition no. from parametes or max(requisition no + 1) from req_header
		select	@requisitionno=isnull(max(requisition_number),0) + 1
		from 	requisition_header
	
		-- rowid for that new row being created 
		select	@rowid=isnull(max(row_id),0) + 1
		from	requisition_detail 
		where	requisition_number=@requisitionno

--		Insert into  requisition header records
		-- insert row into requisition header
		insert 
		into	requisition_header (
			requisition_number, vendor_code, ship_to_destination, terms, 
			fob, requested_date, requisitioner, ship_via, notes, approved,
			approver, creation_date, status, approval_date, freight_type)
		values 	(@requisitionno, @vendor, @shiptodest, @terms, 
			@fob, getdate(), 'kanba', @shipvia, 'Auto Generated Requisition through Kanban procedur', null,
			null, getdate(), '1', null, @freighttype)
		
		-- insert row into requisition detail 
		insert 	
		into	requisition_detail (
			requisition_number, part_number, description, quantity, date_required, row_id, 
			vendor_code, unit_of_measure , unit_cost)
		values	(@requisitionno, @part, @desc, @newqty, @duedate, @rowid,
			@vendor, @stdunit , @price) 
	end -- (2a)
	
--	8.	Get the next part

	fetch	parts
	into	@part,
		@parttype,
		@desc,		
		@stdunit,
		@minonhand,
		@maxonhand,
		@vendor,
		@requisitionno,
		@kanban,
		@shipvia,
		@fob,
		@freighttype,
		@terms,
		@onhand,
		@poquantity
	
end -- (1a)
close parts

deallocate parts

--	9.	Return
Return
GO
