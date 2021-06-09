CREATE TABLE [dbo].[audit_trail]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[serial] [int] NOT NULL,
[date_stamp] [datetime] NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[part] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[quantity] [numeric] (20, 6) NULL,
[remarks] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[price] [numeric] (20, 6) NULL,
[salesman] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[operator] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[from_loc] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[to_loc] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[on_hand] [numeric] (20, 6) NULL,
[lot] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[weight] [numeric] (20, 6) NULL,
[status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[shipper] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[activity] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[workorder] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[std_quantity] [numeric] (20, 6) NULL,
[cost] [numeric] (20, 6) NULL,
[control_number] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plant] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_number] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_account] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suffix] [int] NULL,
[due_date] [datetime] NULL,
[group_no] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_order] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[release_no] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dropship_shipper] [int] NULL,
[std_cost] [numeric] (20, 6) NULL,
[user_defined_status] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[engineering_level] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[posted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parent_serial] [numeric] (10, 0) NULL,
[origin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[destination] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sequence] [int] NULL,
[object_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[part_name] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_date] [datetime] NULL,
[field1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[field2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[show_on_shipper] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tare_weight] [numeric] (20, 6) NULL,
[kanban_number] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dimension_qty_string] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dim_qty_string_other] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[varying_dimension_code] [numeric] (2, 0) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[DEL_Empower_AuditTrail]
ON [dbo].[audit_trail] FOR DELETE
AS
BEGIN
	IF EXISTS (SELECT 1 FROM deleted WHERE posted = 'Y')
		RAISERROR('Deleting a transaction interfaced to Empower GL.',11,1)	

	INSERT INTO
		empower_monitor_po_receiver_transactions
		(
			monitor_audit_trail_id, monitor_transaction_date,
			monitor_part, monitor_part_type, monitor_plant, monitor_product_line, 
			monitor_po_number, monitor_shipper, 
			monitor_standard_quantity, monitor_quantity, monitor_unit_cost, 
			changed_date, changed_user_id
		)
		(SELECT
			deleted.id monitor_audit_trail_id, CONVERT(DATE, deleted.date_stamp) monitor_transaction_date,
			UPPER(LTRIM(RTRIM(deleted.part))) monitor_part, UPPER(LTRIM(RTRIM(part.type))) monitor_part_type, UPPER(LTRIM(RTRIM(deleted.plant))) monitor_plant, UPPER(LTRIM(RTRIM(part.product_line))) monitor_product_line, 
			CONVERT(VARCHAR(25), UPPER(LTRIM(RTRIM(deleted.po_number)))) monitor_po_number, UPPER(LTRIM(RTRIM(deleted.shipper))) monitor_shipper,
			ISNULL(deleted.std_quantity, ISNULL(deleted.quantity, 0)) * -1 monitor_standard_quantity, ISNULL(deleted.quantity, 0) * -1 monitor_quantity, ISNULL(deleted.price, 0) monitor_unit_cost, 
			GETDATE() changed_date, 'MONITOR' changed_user_id
		FROM
			deleted LEFT OUTER JOIN
			part ON
				deleted.part = part.part
		WHERE
			deleted.type = 'R'
		)
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[INS_Empower_AuditTrail]
ON [dbo].[audit_trail] FOR INSERT
AS
BEGIN

	-- insert r types into transactions to be processed

	INSERT INTO
		empower_monitor_po_receiver_transactions
		(
			monitor_audit_trail_id, monitor_transaction_date,
			monitor_part, monitor_part_type, monitor_plant, monitor_product_line, 
			monitor_po_number, monitor_shipper, 
			monitor_standard_quantity, monitor_quantity, monitor_unit_cost, 
			changed_date, changed_user_id
		)
		(SELECT
			inserted.id monitor_audit_trail_id, CONVERT(DATE, inserted.date_stamp) monitor_transaction_date, 
			UPPER(LTRIM(RTRIM(inserted.part))) monitor_part, UPPER(LTRIM(RTRIM(part.type))) monitor_part_type, UPPER(LTRIM(RTRIM(inserted.plant))) monitor_plant, UPPER(LTRIM(RTRIM(part.product_line))) monitor_product_line, 
			CONVERT(VARCHAR(25), UPPER(LTRIM(RTRIM(inserted.po_number)))) monitor_po_number, UPPER(LTRIM(RTRIM(inserted.shipper))) monitor_shipper,
			ISNULL(inserted.std_quantity, ISNULL(inserted.quantity, 0)) monitor_standard_quantity, ISNULL(inserted.quantity, 0) monitor_quantity, ISNULL(inserted.price, 0) monitor_unit_cost, 
			GETDATE() changed_date, 'MONITOR' changed_user_id 
		FROM
			inserted LEFT OUTER JOIN
			part ON
				inserted.part = part.part
		WHERE
			inserted.type = 'R' AND
			ISNULL(inserted.std_quantity, ISNULL(inserted.quantity, 0)) > 0
		)

	IF EXISTS (SELECT 1 FROM empower_preferences WHERE preference = 'MonitorDeleteAndCorrectReceipts' AND preference_value = 'Y')
	BEGIN

		-- insert correction transactions

		-- no work to do if the previous audit_trail type isn't an 'R'.
		-- There is a stored procedure that handles the deletion of an
		-- 'R'. They way it is written will also allow it to handle a
		-- change in quantity on an 'R', so we'll simply call it with
		-- the correct quantity.

		INSERT INTO
			empower_monitor_po_receiver_transactions
			(
				monitor_audit_trail_id, monitor_transaction_date,
				monitor_part, monitor_part_type, monitor_plant, monitor_product_line, 
				monitor_po_number, monitor_shipper, 
				monitor_standard_quantity, 
				monitor_quantity, 
				monitor_unit_cost, 
				changed_date, changed_user_id
			)
			(SELECT
				audit_trail.id monitor_audit_trail_id, CONVERT(DATE, previous_audit_trail.date_stamp) monitor_transaction_date,
				UPPER(LTRIM(RTRIM(previous_audit_trail.part))) monitor_part, UPPER(LTRIM(RTRIM(part.type))) monitor_part_type, UPPER(LTRIM(RTRIM(previous_audit_trail.plant))) monitor_plant, UPPER(LTRIM(RTRIM(part.product_line))) monitor_product_line, 
				CONVERT(VARCHAR(25), UPPER(LTRIM(RTRIM(previous_audit_trail.po_number)))) monitor_po_number, UPPER(LTRIM(RTRIM(previous_audit_trail.shipper))) monitor_shipper,
				CASE WHEN audit_trail.type = 'X' THEN 
					ISNULL(audit_trail.std_quantity, ISNULL(audit_trail.quantity, 0)) - ISNULL(previous_qty_audit_trail.std_quantity, ISNULL(previous_qty_audit_trail.quantity, 0))
				ELSE
					-- there has been discussion about whether the quantity on
					-- a delete will be 0 or the deleted quantity. We won't count
					-- on the value from the delete but will use the value from
					-- the original receipt or previous correction.
					ISNULL(previous_qty_audit_trail.std_quantity, ISNULL(previous_qty_audit_trail.quantity, 0)) * -1
				END monitor_standard_quantity,
				CASE WHEN audit_trail.type = 'X' THEN 
					ISNULL(audit_trail.quantity, 0) - ISNULL(previous_qty_audit_trail.quantity, 0)
				ELSE
					-- there has been discussion about whether the quantity on
					-- a delete will be 0 or the deleted quantity. We won't count
					-- on the value from the delete but will use the value from
					-- the original receipt or previous correction.
					ISNULL(previous_qty_audit_trail.quantity, 0) * -1
				END monitor_quantity,
				ISNULL(previous_audit_trail.price, 0) monitor_unit_cost, 
				GETDATE() changed_date, 'MONITOR' changed_user_id 
			FROM
				inserted audit_trail INNER JOIN
				vw_empower_audit_trail_previous ON
					audit_trail.id = vw_empower_audit_trail_previous.id INNER JOIN
				audit_trail previous_audit_trail ON
					vw_empower_audit_trail_previous.previous_id = previous_audit_trail.id INNER JOIN
				audit_trail previous_qty_audit_trail ON
					vw_empower_audit_trail_previous.previous_qty_id = previous_qty_audit_trail.id LEFT OUTER JOIN
				part ON
					previous_audit_trail.part = part.part 
			WHERE
				previous_audit_trail.type = 'R'
			)
	END	
		
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE trigger [dbo].[mtr_audit_trail_i]
on [dbo].[audit_trail]
for insert
as
-----------------------------------------------------------------------------------------------
--	This trigger concatenates gl segments from various tables & writes to audit_trail
--
--	Modifications:	05 AUG 1999, Harish P. Gubbi	Original.
--
--	Parameters:	None
--
--	Returns:	None
--
--	Process:
--	1. 	Declare variables	
--	2.	Declare cursor for inserted
--	3. 	Loop through each row
--	4.	Get gl tran type code	
--	5.	Get Natural segment from part_gl_account table
--	6.	Get Plant segment from from destination table
--	7.	Get Product line segment from from product line table
-- 	8.	Update audit_trail table with gl_account_no
-- 	9.	Record shipout for homogeneous pallet with part id of boxes.
--	10.	Record shipout for loose box.
-- 	11.	Return 

-----------------------------------------------------------------------------------------------

--	1.	Declare variables
declare @part          varchar(25),
	@plant         varchar(10),
	@productline   varchar(25),
	@type          varchar(1),
	@ttype          varchar(1),
	@parttype     varchar(1),
	@partsubtype  varchar(1),
	@gl_account_no varchar(50),
	@gltrantypest  varchar(25),
	@serial        int

--	2.	Declare cursor for the inserted rows	
declare new_recs cursor for
select	inserted.part,
	inserted.type,
	inserted.plant,
	inserted.serial,
	part.product_line,
	part.class,
	part.type
from	inserted 
	join part on part.part = inserted.part
open	new_recs
fetch	new_recs into  @part, @type, @plant, @serial, @productline, @parttype, @partsubtype

--	3.	Loop through each row
while @@fetch_status = 0
begin -- (1a)

--	4.	Get gl tran type code		
	if @productline is not null
	begin -- (2a)
		select	@gltrantypest =
			(case 
				when @type='A' and @partsubtype='F' then 'Manual Add - Finished Goo' 
				when @type='A' and @partsubtype='W' then 'Manual Add - Wip'
				when @type='A' and @partsubtype='R' then 'Manual Add - Raw'
				when @type='X' 		 	    then 'Change/Correct Object'
				when @type='R' and @partsubtype='F' then 'Receive Finished'
				when @type='R' and @partsubtype='R' then 'Receive Raw'
				when @type='R' and @partsubtype='W' then 'Receive Wip'
				when @type='V' and @partsubtype in ('R','W','F') then 'Return Raw to Vendor'
				when @type='M' and @partsubtype='F' then 'Issue Finished'
				when @type='M' and @partsubtype='R' then 'Issue Raw to Wip'
				when @type='M' and @partsubtype='W' then 'Issue Wip'
				when @type='J' and @partsubtype='F' then 'Complete Finished Goods'
				when @type='J' and @partsubtype='W' then 'Complete Wip'
				when @type='J' and @partsubtype='R' then 'Ship Finished Goods' 
				else ''
			end)
      		-- get the tran type code from gl_tran_type table 		
		select	@ttype=code
		from	gl_tran_type
		where	name = @gltrantypest

--	5.	Get Natural segment from part_gl_account table	
  		select	@gl_account_no= 
  			(case 
  				when @parttype='M' then isnull(part_gl_account.gl_account_no_cr,'')
  				when @parttype='P' then isnull(part_gl_account.gl_account_no_db,'')
  			end)
    		from	part_gl_account
		where	part_gl_account.part=@productline and 
			part_gl_account.tran_type=@ttype

--	6.	Get Plant segment from from destination table
		select	@gl_account_no = 
			(case
				when isnull(@gl_account_no,'') <> '' then
					isnull(@gl_account_no,'') + isnull(destination.gl_segment,'')  
				else
					isnull(destination.gl_segment,'')
			end)
		from	destination
		where   destination.plant=@plant
		
--	7.	Get Product line segment from from product line table
		select	@gl_account_no = 
			(case
				when isnull(@gl_account_no,'') <> '' then
					isnull(@gl_account_no,'') + isnull(product_line.gl_segment,'')	
				else
					isnull(product_line.gl_segment,'')
			end)
  		from 	product_line
 		where   product_line.id=@productline
			
-- 	8.	Update audit_trail table with gl_account_no
      		if (@gl_account_no is not null and @gl_account_no<>'')
         		update	audit_trail
            		set	gl_account=@gl_account_no
          		where	audit_trail.serial = @serial and 
          			type=@type
			
    	end -- (2a)

-- 	9.	Record shipout for homogeneous pallet with part id of boxes.
	--if	@Type = 'S' begin
	--	if	(	select	object_type
	--			from	audit_trail
	--			where	serial = @Serial and
	--				type = 'S') = 'S' begin

	--		insert	serial_asn
	--		select	pallet.serial,
	--			max(boxes.part),
	--			convert(int, pallet.shipper),
	--			pallet.package_type
	--		from	audit_trail pallet
	--			join audit_trail boxes on boxes.parent_serial = @Serial and
	--				boxes.type = 'S'
	--		where	pallet.serial = @Serial and
	--			pallet.type = 'S' and
	--			pallet.object_type = 'S'
	--		group by
	--			pallet.serial,
	--			pallet.shipper,
	--			pallet.package_type
	--		having	count(distinct boxes.part) = 1
	--	end
		
--	10.	Record shipout for loose box.
		--insert	serial_asn
		--select	serial,
		--	part,
		--	convert ( integer, shipper ),
		--	package_type
		--from	audit_trail
		--where	serial = @serial and
		--	parent_serial is null and
		--	object_type is null and
		--	type = 'S'
	--end
		
	fetch	new_recs into	@part, @type, @plant, @serial, @productline, @parttype, 
				@partsubtype
end -- (1a)
close new_recs
deallocate new_recs

--	11.	Return
Return



GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[UPD_Empower_AuditTrail]
ON [dbo].[audit_trail] FOR UPDATE
AS
BEGIN
	INSERT INTO
		empower_monitor_po_receiver_transactions
		(
			monitor_audit_trail_id, monitor_transaction_date,
			monitor_part, monitor_part_type, monitor_plant, monitor_product_line, 
			monitor_po_number, monitor_shipper, 
			monitor_standard_quantity, monitor_quantity, monitor_unit_cost, 
			changed_date, changed_user_id
		)
		(SELECT
			deleted.id monitor_audit_trail_id, CONVERT(DATE, deleted.date_stamp) monitor_transaction_date,
			UPPER(LTRIM(RTRIM(deleted.part))) monitor_part, UPPER(LTRIM(RTRIM(part.type))) monitor_part_type, UPPER(LTRIM(RTRIM(deleted.plant))) monitor_plant, UPPER(LTRIM(RTRIM(part.product_line))) monitor_product_line, 
			CONVERT(VARCHAR(25), UPPER(LTRIM(RTRIM(deleted.po_number)))) monitor_po_number, UPPER(LTRIM(RTRIM(deleted.shipper))) monitor_shipper,
			ISNULL(deleted.std_quantity, ISNULL(deleted.quantity, 0)) * -1 monitor_standard_quantity, ISNULL(deleted.quantity, 0) * -1 monitor_quantity, ISNULL(deleted.price, 0) monitor_unit_cost, 
			GETDATE() changed_date, 'MONITOR' changed_user_id
		FROM
			inserted INNER JOIN
			deleted ON
				inserted.id = deleted.id LEFT OUTER JOIN
			part ON
				inserted.part = part.part
		WHERE
			inserted.type = 'D' AND
			deleted.type = 'R' 
		)
END
GO
ALTER TABLE [dbo].[audit_trail] ADD CONSTRAINT [PK__audit_trail__1273C1CD] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [date_type] ON [dbo].[audit_trail] ([date_stamp], [type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [part_type_to] ON [dbo].[audit_trail] ([part], [type], [to_loc]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [type_for_objhist_u] ON [dbo].[audit_trail] ([posted], [type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [audit_trail_serial_datestamp_ix] ON [dbo].[audit_trail] ([serial], [date_stamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [audit_trail_shipper_ix] ON [dbo].[audit_trail] ([shipper]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_AuditTrail_1] ON [dbo].[audit_trail] ([type], [part], [date_stamp]) INCLUDE ([cost]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_AuditTrail_PO] ON [dbo].[audit_trail] ([type], [po_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [audit_trail_workorder_ix] ON [dbo].[audit_trail] ([workorder]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [workorder_type] ON [dbo].[audit_trail] ([workorder], [type]) ON [PRIMARY]
GO
