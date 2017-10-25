SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[msp_create_wo_po] as
-------------------------------------------------------------------------------------------------
--	Procedure	msp_create_wo_po
--	Purpose		To create work orders or po releases for all the parts onhand falls
--			below the minimum level Applicable to all the kanban part
--	Arguments	None
--
--	Development	Developer	Date	Description
--			GPH		No idea	Created long time back
--			GPH		4/27/01	Included a procedure call at the end of the proc
--
------------------------------------------------------------------------------------------------
--	Declare variables
declare	@onhand           dec(20,6),      @min_onhand      dec(20,6),       @max_onhand      dec(20,6),
	@part             varchar(25),    @vendor          varchar(10),     @prev_part       varchar(25),
	@part_type        char(1),        @part_class      char(1),         @work_order      varchar(10),
	@machine_no       varchar(10),    @due_date        datetime,        @process_id      varchar(25),
	@setup_time       int,            @cycle_time      int,             @runtime         numeric(15,7),
	@cycle_unit       varchar(15),    @parts_per_hour  numeric(7,3),    @parts_per_cycle numeric(7,3),
	@new_qty_sum      numeric(20,6),  @new_qty         numeric(20,6),   @include_set_up  char(1),
	@trusted          varchar(1),     @po_number       int,             @rowid           numeric(20,0),
	@desc             varchar(40),    @uom             varchar(2),      @crp             varchar(25),
	@account_code     varchar(50),    @price           numeric(20,6),   @release_no      int,
	@ship_to_dest     varchar(25),    @terms           varchar(20),     @week_no         int,
	@plant            varchar(10),    @standard_qty    numeric(20,6),   @ship_via        varchar(15),
	@ship_type        varchar(1),     @status          varchar(1),      @leaddays        int,
	@dFiscalYearBegin datetime,       @idays           int,             @iweek           int,
	@mindaysonhand    int,            @location        varchar(10),     @prev_locn       varchar(10),
	@dmdqty           numeric(20,6),  @howmanydays     int,             @hours           int,
	@enddate          datetime,       @endtime         datetime,        @dest            varchar(10),
	@prev_dest        varchar(10),    @orderno         int,             @customer        varchar(10),
	@stdpack          numeric(20,6),  @note            varchar(255),
	@kanban           char(1),	  @requisition	   char(1)
	
create table #tmp_partloc (	location varchar(10) not null,
				days_onhand numeric(20,6) null,
				min_onhand  numeric(20,6) null,
				max_onhand  numeric(20,6) null )
				
create table #tmp_dest (	destination varchar(10) not null,
				order_no    int not null)
select @prev_part=''

begin transaction

--	Get the setup time
select	@include_set_up=include_setuptime,
	@dFiscalYearBegin=fiscal_year_begin,
	@requisition = isnull(requisition,'N') 
from	parameters

--	Get each row of information from part,part_inventory,part_online table
set rowcount 1

select	@part		= part.part,
	@part_type	= part.type,
	@part_class	= part.class,
	@desc		= part.name,
	@crp		= part.cross_ref,
	@uom		= part_inventory.standard_unit,
	@onhand		= isnull(part_online.on_hand,0),
	@min_onhand	= isnull(part_online.min_onhand,0),
	@max_onhand	= isnull(part_online.max_onhand,0),
	@vendor		= part_online.default_vendor,
	@po_number	= part_online.default_po_number
from	part,part_inventory,part_online
where	(part.part > @prev_part) and
	(part_inventory.part=part.part) and
	(part_online.part=part.part)
order by part.part   

--	while rowcount is greater than 0 
while @@rowcount>0
begin	-- 2b
	select @due_date=convert( datetime, (substring(convert(varchar(19), getdate()),1,11)))
	--	check type & class
	if @part_class='M'	-- if it's a manufactured part
	begin	-- 3b 
		if @part_type='F'  -- if it's a finished part
		begin	-- 4b 
			--	append all the destinations & order_no for that part from order_header table
			set rowcount 0
			insert	#tmp_dest (destination,order_no)
			select	destination,order_no
			from	order_header
			where	order_header.blanket_part=@part
			order by destination
			
			--	check whether the tmp table is populated or not 
			if @@rowcount>0
			begin	-- 4.1b
				select @prev_dest=''
				--	Get the 1st destination from the tmp table
				set rowcount 1
				select	@dest=destination,
					@orderno=order_no
				from	#tmp_dest
				--	process for all the locations
				while @@rowcount > 0
				begin	-- 4.2b
					set rowcount 0 
					select	@customer=isnull(customer,''),
						@stdpack =isnull(standard_pack,0),
						@orderno=order_no
					from	order_header
					where	destination=@dest and order_no=@orderno
					set rowcount 0 
					--	append all the locations for that part from part location table
					insert	#tmp_partloc (location,days_onhand,min_onhand,max_onhand)
					select	location,days_onhand,minimum,maximum
					from	part_location
					where	part_location.part=@part and
						part_location.destination=@dest
					order by location 
					--	check whether the tmp table is populated or not 
					if @@rowcount>0
					begin	-- 5b
						select @prev_locn=''
						--	Get the 1st location from the tmp table
						set rowcount 1
						select	@location=location,
							@mindaysonhand=isnull(days_onhand,0),
							@min_onhand=isnull(min_onhand,0),
							@max_onhand=isnull(max_onhand,0)
						from	#tmp_partloc
						--	Process for all the locations
						while @@rowcount > 0
						begin	-- 6b
							--	Get onhand quantity from object table
							select	@onhand=isnull(sum(quantity),0)
							from	object
							where	part=@part and location=@location
							--	Get the demand quantity from order_detail table
							if @mindaysonhand>0
							begin	-- 6.1b
								select	@dmdqty=isnull(sum(quantity),0)
								from	order_detail,order_header
								where	order_header.blanket_part=@part and order_header.destination=@dest and
									order_header.order_no = order_detail.order_no and   
									order_detail.due_date <= dateadd(dd, isnull(@mindaysonhand,0), @due_date)
							end	-- 6.1b
							else
							begin	-- 6.2b
								if @onhand<@min_onhand    
									select @dmdqty=@max_onhand
								else
									select @dmdqty=@min_onhand
							end	-- 6.2b
							--	check dmd qty vs onhand
							if @dmdqty > @onhand
							begin	-- 6.3b
								select @new_qty= @dmdqty - @onhand
								--	Check whether work order quantity is greater than 0 & then proceed
								--	Get the work order quantity
								select	@new_qty_sum= isnull(sum(isnull(qty_required,0) -  isnull(qty_completed,0)),0)
								from	workorder_detail
								where	part = @part
								--	Check whether the summed quantity is less than the max onhand             
								if @new_qty_sum < @new_qty
								begin	-- 6.4b 
									--	Compute the new quantity for the work order to be created
									select @new_qty= (@new_qty - @new_qty_sum)  
									--	Check whether work order quantity is greater than 0 & then proceed
									if @new_qty > 0
									begin 	-- 6.5b
										set rowcount 1
										--	Get part details from part_mfg
										select	@process_id=isnull(part_mfg.process_id,'none'),
											@cycle_time=isnull(part_mfg.cycle_time,1),
											@cycle_unit=part_mfg.cycle_unit,
											@parts_per_hour=isnull(part_mfg.parts_per_hour,1),
											@parts_per_cycle=isnull(part_mfg.parts_per_cycle,1),
											@setup_time = isnull(part_mfg.setup_time,0),     
											@runtime = @new_qty * isnull((1 / part_mfg.parts_per_hour),0),
											@machine_no=part_machine.machine
										from	part_mfg,part_machine
										where 	part_mfg.part=@part and part_machine.part=@part
										
										--	Get end date & time 
										select	@enddate= @due_date,
											@endtime= @due_date      
										
										--	Include setup time with runtime is if it is set to y in parameter table
										if @include_set_up = 'Y'
											select	@runtime = @runtime + isnull(@setup_time,0)
										--	If the machine no is null get it from part_inventory table 
										if @machine_no is null
											select	@machine_no=primary_location
											from	part_inventory
											where	part=@part
										--	get next work order number from parameters table
										select	@work_order=convert(varchar,next_workorder)
										from	parameters
										select	@note='Auto generated work order & standard pack qty for the part '+@part+': '+ltrim(convert(varchar(16),@stdpack))
										set rowcount 0 
										--	Insert data into work order header                  
										insert 
										into	work_order 
											(work_order,machine_no,sequence,due_date,process_id,setup_time, 
											cycle_time,start_date,start_time,end_date,end_time,runtime,cycle_unit,
											note,order_no,destination,customer)    
										values	(@work_order,@machine_no,9999,@due_date,@process_id,@setup_time,
											@cycle_time,@due_date,@due_date,@enddate,@endtime,@runtime,@cycle_unit,
											@note,@orderno,@dest,@customer) 
										--	Insert data into work order detail
										insert 
										into	workorder_detail
											(workorder,part,qty_required,qty_completed,parts_per_cycle,run_time,
											balance,parts_per_hour) 
										values	(@work_order,@part,@new_qty,0,@parts_per_cycle,@runtime,@new_qty,
											@parts_per_hour)
										--	Get next work order number
										update parameters set next_workorder=convert(numeric,@work_order) + 1
									end	-- 6.5b
								end	-- 6.4b
							end	-- 6.3b
							select	@prev_locn=@location
							--	Delete the current location from the temp table
							set rowcount 0 
							delete 
							from	#tmp_partloc
							where	location=@location
							--	Get the 1st location from the tmp table
							set rowcount 1
							select	@location=location,
								@mindaysonhand=isnull(days_onhand,0),
								@min_onhand=isnull(min_onhand,0),
								@max_onhand=isnull(max_onhand,0)
							from	#tmp_partloc
						end	-- 6b
					end	-- 5b
					select	@prev_dest=@dest
					--	Delete the current location from the temp table
					set rowcount 0 
					delete 
					from	#tmp_dest
					where	destination=@dest
					--	Get the next dest from the tmp table
					set rowcount 1
					select	@dest=destination,
						@orderno=order_no
					from	#tmp_dest
				end	-- 4.2b
			end	-- 4.1b 
			else
			begin	-- 9b
				-- 	Get onhand quantity from object table for that part
				select	@onhand=isnull(sum(quantity),0)
				from	object
				where	part=@part and status='A'
				if @onhand <= @min_onhand -- if onhand quantity is less than the minimum onhand then proceed
				begin	-- 10b
					--	Compute the new quantity for the work order/po to be created
					select	@new_qty= @max_onhand - @onhand
					-- get the work order quantity
					select	@new_qty_sum= isnull(sum(isnull(qty_required,0) -  isnull(qty_completed,0)),0)
					from	workorder_detail
					where	part = @part
					--	Check whether the summed quantity is less than the max onhand             
					if @new_qty_sum < @max_onhand
					begin	-- 11b 
						--	Compute the new quantity for the work order to be created
						select @new_qty= @new_qty - @new_qty_sum
					
						--	Check whether work order quantity is greater than 0 & then proceed
						if @new_qty > 0
						begin	-- 12b
							set rowcount 1 
							--	Get part details from part_mfg
							select	@process_id=isnull(part_mfg.process_id,'none'),
								@cycle_time=isnull(part_mfg.cycle_time,1),
								@cycle_unit=part_mfg.cycle_unit,
								@parts_per_hour=isnull(part_mfg.parts_per_hour,1),
								@parts_per_cycle=isnull(part_mfg.parts_per_cycle,1),
								@setup_time = isnull(part_mfg.setup_time,0), 
								@runtime = @new_qty * isnull((1 / part_mfg.parts_per_hour),0),
								@machine_no=part_machine.machine
							from	part_mfg,part_machine
							where	part_mfg.part=@part and part_machine.part=@part
							
							--	Get end date & time 
							select	@enddate= @due_date,
								@endtime= @due_date 
							-- include setup time with runtime is if it is set to y in parameter table
							if @include_set_up = 'Y'
								select	@runtime = @runtime + isnull(@setup_time,0)
							-- if the machine no is null get it from part_inventory table 
							if @machine_no is null
								select	@machine_no=primary_location
								from	part_inventory
								where	part=@part
							--	Get next work order number from parameters table
							select	@work_order=convert(varchar,next_workorder)
							from	parameters
							set rowcount 0
							--	Insert data into work order header 
							insert 
							into	work_order 
								(work_order,machine_no,sequence,due_date,process_id,setup_time, 
								cycle_time,start_date,start_time,end_date,end_time,runtime,cycle_unit,
								note,order_no,destination,customer)    
							values	(@work_order,@machine_no,9999,@due_date,@process_id,@setup_time,
								@cycle_time,@due_date,@due_date,@enddate,@endtime,@runtime,@cycle_unit,
								'Auto generated work order',0,'','') 
							--	Insert data into work order detail
							insert 
							into	workorder_detail
								(workorder,part,qty_required,qty_completed,parts_per_cycle,run_time,
								balance,parts_per_hour) 
							values	(@work_order,@part,@new_qty,0,@parts_per_cycle,@runtime,@new_qty,@parts_per_hour)
							--	Get next work order number
							update parameters set next_workorder=convert(numeric,@work_order)+1
						end	-- 12b
					end	-- 11b
				end	-- 10b
			end	-- 9b
		end	-- 4b 
		else	-- if it's a manufactured wip or raw part
		begin	-- 9b
			-- 	Get onhand quantity from object table for that part
			select	@onhand=isnull(sum(quantity),0)
			from	object
			where	part=@part and status='A'
			if @onhand <= @min_onhand -- if onhand quantity is less than the minimum onhand then proceed
			begin	-- 10b
				--	Compute the new quantity for the work order/po to be created
				select	@new_qty= @max_onhand - @onhand
				-- get the work order quantity
				select	@new_qty_sum= isnull(sum(isnull(qty_required,0) -  isnull(qty_completed,0)),0)
				from	workorder_detail
				where	part = @part
				--	Check whether the summed quantity is less than the max onhand             
				if @new_qty_sum < @max_onhand
				begin	-- 11b 
					--	Compute the new quantity for the work order to be created
					select @new_qty= @new_qty - @new_qty_sum
				
					--	Check whether work order quantity is greater than 0 & then proceed
					if @new_qty > 0
					begin	-- 12b
						set rowcount 1 
						--	Get part details from part_mfg
						select	@process_id=isnull(part_mfg.process_id,'none'),
							@cycle_time=isnull(part_mfg.cycle_time,1),
							@cycle_unit=part_mfg.cycle_unit,
							@parts_per_hour=isnull(part_mfg.parts_per_hour,1),
							@parts_per_cycle=isnull(part_mfg.parts_per_cycle,1),
							@setup_time = isnull(part_mfg.setup_time,0), 
							@runtime = @new_qty * isnull((1 / part_mfg.parts_per_hour),0),
							@machine_no=part_machine.machine
						from	part_mfg,part_machine
						where	part_mfg.part=@part and part_machine.part=@part
						
						--	Get end date & time 
						select	@enddate= @due_date,
							@endtime= @due_date 
						-- include setup time with runtime is if it is set to y in parameter table
						if @include_set_up = 'Y'
							select	@runtime = @runtime + isnull(@setup_time,0)
						-- if the machine no is null get it from part_inventory table 
						if @machine_no is null
							select	@machine_no=primary_location
							from	part_inventory
							where	part=@part
						--	Get next work order number from parameters table
						select	@work_order=convert(varchar,next_workorder)
						from	parameters
						set rowcount 0
						--	Insert data into work order header 
						insert 
						into	work_order 
							(work_order,machine_no,sequence,due_date,process_id,setup_time, 
							cycle_time,start_date,start_time,end_date,end_time,runtime,cycle_unit,
							note,order_no,destination,customer)    
						values	(@work_order,@machine_no,9999,@due_date,@process_id,@setup_time,
							@cycle_time,@due_date,@due_date,@enddate,@endtime,@runtime,@cycle_unit,
							'Auto generated work order',0,'','') 
						--	Insert data into work order detail
						insert 
						into	workorder_detail
							(workorder,part,qty_required,qty_completed,parts_per_cycle,run_time,
							balance,parts_per_hour) 
						values	(@work_order,@part,@new_qty,0,@parts_per_cycle,@runtime,@new_qty,@parts_per_hour)
						--	Get next work order number
						update parameters set next_workorder=convert(numeric,@work_order)+1
					end	-- 12b
				end	-- 11b
			end	-- 10b
		end	-- 9b
	end	-- 3b 
	else if (@part_class='P')    -- if it's a purchased part        
	begin	-- 13b
		--	Get onhand quantity from object table for that part
		select	@onhand=isnull(sum(quantity),0)
		from	object
		where	part=@part and status='A'
		
		if @onhand <= @min_onhand -- if onhand quantity is less than the minimum onhand then proceed
		begin	-- 14b
			--	Compute the new quantity for the work order/po to be created
			select	@new_qty= @max_onhand - @onhand
			--	Check whether the vendor has been specified for that part 
			if @vendor is not null
			begin	-- 15b
				--	Check whether the vendor is a trusted vendor or not 
				select	@kanban=kanban
				from	vendor
				where	code=@vendor
				-- if vendor is a trusted vendor then proceed with the creation of po
				if @kanban='Y'
				begin	-- 16b
					if @po_number is null
					begin	-- 16.1b
						--	Get po number from po header table for that vendor
						set rowcount 1 
						select	@po_number=po_number
						from	po_header
						where	vendor_code=@vendor and status='A'
					end	-- 16.1b
					--	If a valid po exist for that vendor
					if @po_number > 0
					begin	-- 16.2b
						set rowcount 0 
						--	Get the po quantity from existing releases
						select	@new_qty_sum= isnull(sum(isnull(balance,0)),0)
						from	po_detail
						where	po_detail.part_number = @part and po_detail.po_number=@po_number and
							isnull(po_detail.deleted,'N')<>'Y'
						--	Check whether the summed quantity is less than the max onhand             
						if @new_qty_sum < @max_onhand
						begin -- 16.3b 
							--	Compute the new quantity for the po to be created
							select	@new_qty= (@new_qty - @new_qty_sum)  
							--	Check whether work order quantity is greater than 0 & then proceed
							if @new_qty > 0
							begin	-- 16.4b
								--	Get details from po_header
								select	@release_no=release_no,
									@ship_to_dest=ship_to_destination,
									@terms = terms,
									@plant = plant,
									@ship_type=ship_type,
									@ship_via=ship_via,
									@status = status
								from	po_header
								where	po_header.po_number=@po_number
								--	Get details from part_vendor & part_vendor_price_matrix                    
								select	@standard_qty=isnull(vendor_standard_pack,0),
									@leaddays = isnull(lead_time,0), 
									@price = isnull(price,0)
								from	part_vendor,part_vendor_price_matrix
								where	part_vendor.part=@part and part_vendor.vendor=@vendor and 
									part_vendor_price_matrix.part=@part and 
									part_vendor_price_matrix.vendor=@vendor
								--	Rowid for that new row being created 
								select	@rowid=isnull(max(row_id),0) + 1
								from	po_detail 
								where	po_number=@po_number
		
								--	Get part details from part,part_purchasing table 
								select	@desc=part.name,
									@uom =part_inventory.standard_unit,
									@crp =part.cross_ref,
									@account_code=part_purchasing.gl_account_code
								from	part,part_purchasing,part_inventory
								where	part.part=@part and
									part_purchasing.part=@part and
									part_inventory.part=@part
								--	Get the no. of days from the fiscal year begin
								select	@idays = datepart(dd,@dfiscalyearbegin)
								--	calculate the week number
								select	@iweek = ((datediff(dd,@dfiscalyearbegin, dateadd(dd, isnull(@leaddays,0), 
										@due_date)) + @idays) / 7) + 1
								--	insert row into po detail 
								insert 
								into	po_detail
									(po_number,part_number,date_due,row_id,vendor_code,description,
									unit_of_measure,status,cross_reference_part,account_code,notes,
									quantity,received,balance,release_no,ship_to_destination,terms,week_no,
									plant,standard_qty,ship_type,printed,ship_via, alternate_price)        
								values	(@po_number,@part, dateadd(dd, isnull(@leaddays,0), @due_date),@rowid,
									@vendor,@desc,@uom,@status,@crp,@account_code,'auto generated release',
									@new_qty,0,@new_qty,@release_no,@ship_to_dest,@terms,@iweek,@plant,
									@new_qty,@ship_type,'N',@ship_via, @price) 
						
							end	-- 16.4b
						end	-- 16.3b
					end	-- 16.2b
				end	-- 16b
			end	-- 15b
		end	-- 14b 
	end	-- 13b
	--	Update the master_prod_sched table qty_assigned column with this quantity ???
	--	Assign the current part to the previous part variable
	select	@prev_part=@part  
	-- get the next part for processing from the part table.
	set rowcount 1
	select	@part=part.part,
		@part_type=part.type,
		@part_class=part.class,
		@desc=part.name,
		@crp=part.cross_ref,
		@uom=part_inventory.standard_unit,
		@onhand=isnull(part_online.on_hand,0),
		@min_onhand=isnull(part_online.min_onhand,0),
		@max_onhand=isnull(part_online.max_onhand,0),
		@vendor=part_online.default_vendor,
		@po_number=part_online.default_po_number  
	from	part,part_inventory,part_online
	where	part.part > @prev_part and
		part_inventory.part=part.part and
		part_online.part=part.part
	order by part.part
end	-- 2b
if @requisition ='Y'
begin
	set rowcount 0 
	execute msp_create_requisitionrel
end 	
commit transaction
--	Added this procedure call, so that, it recalc runtime for that machine 
--	and re-sequences work orders on that machine
execute msp_recalc_tasks
set rowcount 0 
GO
