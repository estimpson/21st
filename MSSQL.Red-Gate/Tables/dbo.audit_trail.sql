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

CREATE TRIGGER [dbo].[Delete_AuditTrailMonitor]
ON [dbo].[audit_trail] FOR DELETE
AS

-- 17-Apr-08 Removed references to preferences_site.

-- 09-Apr-04 Use the quantity, not the std_quantity, when the preference
--           MonitorStandardCost is 'N'.

-- 23-Feb-2004 Created from SQLAnywhere version.

BEGIN
  DECLARE @s_posted   char(1),
          @s_type     varchar(2),
          @s_shipper  varchar(20),
          @s_ponumber varchar(25),
          @s_part     varchar(25),
          @c_quantity numeric(18,6),
          @c_stdquantity numeric(18,6),
          @i_rowcount int,
          @dt_datestamp datetime,
          @s_usestdcost char(1)

  -- Make sure that we have a row in the deleted table for processing
  SELECT @i_rowcount = Count(*) FROM deleted

  IF @i_rowcount > 0
    BEGIN
     -- Get the preference that indicates if standard or actual cost
     -- should be used.
     SELECT @s_usestdcost = IsNull(value,'')
       FROM preferences_standard
      WHERE preference = 'MonitorStandardCost'
     IF @@rowcount = 0 OR @s_usestdcost = '' SELECT @s_usestdcost = 'Y'

      -- To eliminate duplicate code, use a cursor whether one or multiple
      -- rows are deleted.
      DECLARE delauditcursor CURSOR FOR
        SELECT IsNull(posted,'N'),
               IsNull(type,''), 
               LTrim(RTrim(IsNull(shipper,''))),
               LTrim(RTrim(IsNull(po_number,''))), 
               IsNull(part,''), 
               IsNull(quantity,0),
               IsNull(std_quantity,0),
               date_stamp 
          FROM deleted

      OPEN delauditcursor

      WHILE 1 = 1
        BEGIN
          FETCH delauditcursor 
           INTO @s_posted, @s_type, @s_shipper, @s_ponumber, @s_part,
                @c_quantity, @c_stdquantity, @dt_datestamp

          IF @@fetch_status <> 0 BREAK

          -- Don't allow a row to be deleted if it's gone to GL.
          IF @s_posted = 'Y' 
            --RAISERROR('Transactions interfaced to Empower GL cannot be deleted.',11,1)
            RAISERROR('Deleting a transaction interfaced to Empower GL.',11,1)
          ELSE
            BEGIN
              IF @s_type = 'R'
                -- Update the Empower receiver for this audit trail delete.
                BEGIN
                  IF @s_usestdcost = 'Y' SELECT @c_quantity = @c_stdquantity 
                  SELECT @c_quantity = 0 - @c_quantity
                  EXECUTE CorrectEmpowerReceiver @s_ponumber,
                                                 @s_shipper,
                                                 @s_part,
                                                 @c_quantity,
                                                 @dt_datestamp
                END
            END
        END

      CLOSE delauditcursor
      DEALLOCATE delauditcursor
  END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[Insert_AuditTrailMonitor]
ON [dbo].[audit_trail] FOR INSERT
AS

-- 17-Jan-13 Added code to processes 'D' and 'X' transaction types only when
--           'MonitorDeleteAndCorrectReceipts' is Y which is the default value.
--           Per Andre, Empire is the only customer who wants to process D and X
--           for receipts.

-- 13-Jun-12 When using standard costing, process the 'R' row if the standard
--           quantity is not zero.  Previously, we processed the 'R' row only 
--           if the quantity was not zero.  It's possible for a row with 0 in
--           the quantity to have a value in the standard quantity.

-- 21-May-10 Handle negative receivers created by FX.
 
-- 26-Oct-09 Per Andre, only process type 'D' rows if the remarks
--           are not 'Scrap'.

-- 25-Sep-09 Include Empire type Y rows with the same datestamp
--           when getting the previous audit trail row for D
--           transactions.

-- 17-Apr-08 Get the default fiscal year from preferences_standard 
--           rather than preferences_site because preferences_site is no 
--           longer being used. Removed references to preferences_site.

-- 10-Apr-08 If @@rowcount is 0 after selecting the rni account
--           from vendors or the expense account from po_items,
--           set the corresponding account to an empty string.

-- 30-Sep-04 Right trim the account segment and plant segment.

-- 28-Sep-04 Use the audit_trail price, not the cost, when
--           MonitorStandardCost is 'N'. The price is the PO price.
--           The cost is the standard cost from part_standard.

-- 09-Apr-04 1. Exclude transfers when getting the previous audit trail
--              row for X and D transactions.
--           2. Use the audit_trail quantity, not the std_quantity, when
--              MonitorStandardCost is 'N'. The standard quantity and
--              standard cost relate to the standard unit of measure.
--              The quantity is in the unit of measure of the document.

-- 23-Feb-2004 Created from SQLAnywhere version.

BEGIN
  DECLARE @i_rowcount            INTEGER,
          @s_type                varchar(2),
          @s_shipper             VARCHAR(25),
          @s_invoice             VARCHAR(25),
          @s_ponumber            VARCHAR(25),
          @s_vendor              VARCHAR(25),
          @s_part                VARCHAR(25),
          @s_plant               VARCHAR(25),
          @s_remarks             VARCHAR(25),
          @i_serial              INTEGER,
          @dt_datestamp          DATETIME,
          @s_exponreceipt        char(1),
          @s_usestdcost          char(1),
          @s_fiscalyear          VARCHAR(5),
          @s_ledger              VARCHAR(25),
          @i_period              INTEGER,
          @s_parttype            char(1),
          @s_partdesc            VARCHAR(250),
          @s_productline         VARCHAR(25),
          @s_plantaccount        VARCHAR(25),
          @s_productlineaccount  VARCHAR(25),
          @s_itemledgeraccount   VARCHAR(50),
          @s_rniaccount          VARCHAR(25),
          @s_rniledgeraccount    VARCHAR(50),
          @s_currency            VARCHAR(25),
          @s_receiver            VARCHAR(25),
          @c_cost                NUMERIC(18,6),
          @c_quantity            NUMERIC(18,6),
          @c_stdquantity         NUMERIC(18,6),
          @c_amount              NUMERIC(18,6),
          @i_count               INTEGER,
          @i_bolline             SMALLINT,
          @s_havehdr             char(1),
          @dt_recvddate          DATETIME,
          @s_draccounttable      VARCHAR(25),
          @s_accountstyle        VARCHAR(25),
          @s_appenddate          char(1),
          @s_prevtype            varchar(2),
          @s_prevponumber        VARCHAR(25),
          @s_prevshipper         VARCHAR(25),
          @s_prevpart            VARCHAR(25),
          @c_prevquantity        NUMERIC(18,6),
          @c_prevstdquantity     NUMERIC(18,6),
          @dt_prevdatestamp      DATETIME,
          @c_quantitychg         NUMERIC(18,6),
          @s_vendorname          VARCHAR(40),
          @s_deletecorrectreceipts char(1)


-- Make sure that we have a row in the inserted table for processing
SELECT @i_rowcount = Count(*) FROM inserted

IF @i_rowcount > 0
 BEGIN
  -- Get the preference that indicates if we need to append 
  -- the date to the shipper.
  SELECT @s_appenddate = IsNull(value,'')
    FROM preferences_standard
   WHERE preference = 'MonitorAppendDateToShipper'
  IF @@rowcount = 0 OR @s_appenddate = '' SELECT @s_appenddate = 'Y'

  -- Get the preference that indicates if standard or actual cost
  -- should be used.
  SELECT @s_usestdcost = IsNull(value,'')
    FROM preferences_standard
   WHERE preference = 'MonitorStandardCost'
  IF @@rowcount = 0 OR @s_usestdcost = '' SELECT @s_usestdcost = 'Y'

  -- Get the preference that indicates where to get the RNI account.
  SELECT @s_draccounttable = IsNull(value,'')
    FROM preferences_standard
   WHERE preference = 'MonitorReceivedDRAccountTable'
  IF @@rowcount = 0 OR @s_draccounttable = ''
    SELECT @s_draccounttable = 'Inventory Accounts'

  -- Get the preference that indicates if we need to append segments.
  SELECT @s_accountstyle = IsNull(value,'')
    FROM preferences_standard
   WHERE preference = 'MonitorInventoryAccountsStyle'
  IF @@rowcount = 0 OR @s_accountstyle = '' SELECT @s_accountstyle = 'Account'

  -- Get the preference that indicates if we need to process D and X types.
  SELECT @s_deletecorrectreceipts = IsNull(value,'')
    FROM preferences_standard
   WHERE preference = 'MonitorDeleteAndCorrectReceipts'
  IF @@rowcount = 0 OR @s_deletecorrectreceipts = '' SELECT @s_deletecorrectreceipts = 'Y'

  -- To eliminate duplicate code, use a cursor whether one or multiple
  -- rows are deleted.
  DECLARE insauditcursor CURSOR FOR
    SELECT serial,
           date_stamp, 
           IsNull(type,''), 
           LTrim(RTrim(Upper(IsNull(shipper,'')))),
           LTrim(RTrim(IsNull(po_number,''))), 
           IsNull(part,''), 
           IsNull(plant,''), 
           LTrim(RTrim(IsNull(vendor,''))), 
           IsNull(quantity,0),
           IsNull(std_quantity,0),
           IsNull(price,0),
           LTrim(RTrim(IsNull(remarks,''))) 
      FROM inserted

  OPEN insauditcursor
   WHILE 1 = 1
    BEGIN
     FETCH insauditcursor 
      INTO @i_serial, @dt_datestamp, @s_type, @s_shipper, @s_ponumber, 
           @s_part, @s_plant, @s_vendor, @c_quantity, @c_stdquantity, 
           @c_cost, @s_remarks

     IF @@fetch_status <> 0 BREAK

     -- Only process this audit trail row if it's a receipt.
     IF @s_type = 'R'
      BEGIN

        -- When using the standard cost, we're to use the standard quantity
        IF @s_usestdcost = 'Y' SELECT @c_quantity = @c_stdquantity

        IF @c_quantity > 0 
         BEGIN

           -- Get the date portion of the date/time stamp
           SELECT @dt_recvddate = 
              Convert(datetime,Convert(char(8),@dt_datestamp,112))
    
           IF @s_appenddate = 'Y'
             SELECT @s_shipper = @s_shipper + 
                                '_' + Convert(char(6),@dt_datestamp,12)

           -- If necessary, get the standard cost for the part. When we're
           -- using the standard cost, we should also use the standard quantity.
           IF @s_usestdcost = 'Y'
             BEGIN
               SELECT @c_cost = IsNull(cost_cum,0)
                 FROM part_standard
                WHERE part = @s_part
             END

           IF @c_cost IS NULL SELECT @c_cost = 0
           IF @c_quantity IS NULL SELECT @c_quantity = 0

           -- Calculate an amount for this item based on the received 
           -- quantity and the cost (standard or actual PO price).
           SELECT @c_amount = ROUND(@c_quantity * @c_cost, 2)
    
           -- Was this Monitor PO expensed on receipt?
           SELECT @s_exponreceipt = IsNull(expense_on_receipt,'N')
             FROM po_headers
            WHERE purchase_order = @s_ponumber

           IF @@rowcount = 0 SELECT @s_exponreceipt = 'N'

           -- Is this shipper/part already in the po_receiver_items 
           -- table? If it is, has it been invoiced?
           SELECT @i_bolline = bol_line,
                  @s_invoice = IsNull(invoice,'')
             FROM po_receiver_items 
            WHERE po_receiver_items.purchase_order = @s_ponumber
              AND po_receiver_items.bill_of_lading = @s_shipper
              AND po_receiver_items.item = @s_part

           IF @@rowcount > 0 AND @i_bolline > 0
            BEGIN
             -- found the PO receiver item.
             -- assume that if we have an item, we have a header
             SELECT @s_havehdr = 'Y'
             IF @s_invoice = ''
              -- we can only update the receiver item if it hasn't
              -- been invoiced.
              BEGIN
               -- Update the quantity and amount on the receiver 
               -- item row.
               UPDATE po_receiver_items
                  SET quantity_received = quantity_received + @c_quantity,
                      total_cost = total_cost + @c_amount,
                      changed_date = GetDate(), 
                      changed_user_id = 'MONITOR'
                WHERE po_receiver_items.purchase_order = @s_ponumber
                  AND po_receiver_items.bill_of_lading = @s_shipper
                  AND po_receiver_items.item = @s_part

               IF @s_exponreceipt = 'Y'
                 -- Now update the item GL cost transaction. We'll 
                 -- update the header GL cost transaction below.
                 UPDATE gl_cost_transactions
                    SET quantity = quantity + @c_quantity,
                        amount = amount + @c_amount,
                        document_amount = document_amount + @c_amount, 
                        changed_date = GetDate(), 
                        changed_user_id = 'MONITOR'
                  WHERE document_type = 'BILL OF LADING'
                    AND document_id1 = @s_ponumber
                    AND document_id2 = @s_shipper
                    AND document_id3 = ''
                    AND document_line = @i_bolline
              -- end receiver isn't invoiced
              END
            -- end receiver exists
            END
           ELSE
            BEGIN
             -- This shipper/part does not already exist as a PO 
             -- receiver item row so we'll need to create one.

             -- Since the PO receiver item row doesn't exist, it can't be
             -- invoiced.
             SELECT @s_invoice = ''
    
             -- We need the vendor name for reference 2
             SELECT @s_vendorname = vendor_name 
               FROM vendors 
              WHERE vendor = @s_vendor

             -- We need the ledger and currency from the PO header
             SELECT @s_ledger = ledger, 
                    @s_currency = currency
               FROM po_headers 
              WHERE po_headers.purchase_order = @s_ponumber

             -- Do we already have a receiver header for this shipper?
             SELECT @s_fiscalyear = fiscal_year,
                    @i_period = period
               FROM po_receivers 
              WHERE po_receivers.purchase_order = @s_ponumber
                AND po_receivers.bill_of_lading = @s_shipper

             IF @@rowcount > 0
              BEGIN
               -- already have a receiver header. Set a flag so that we know 
               -- to update the header GL cost transactions
               SELECT @s_havehdr = 'Y'
              END
             ELSE
              BEGIN 
               -- Don't already have a receiver header. Need to 
               -- create one.
               SELECT @s_havehdr = 'N'

               -- We need to establish the fiscal year and period 
               -- for the receipt
               SELECT @s_fiscalyear = value 
                 FROM preferences_standard 
                WHERE preference = 'GLFiscalYear'

               SELECT @i_period = period
                 FROM ledger_definition, calendar_periods 
                WHERE ledger_definition.ledger = @s_ledger
                  AND ledger_definition.fiscal_year = @s_fiscalyear
                  AND ledger_definition.calendar = calendar_periods.calendar 
                  AND calendar_periods.fiscal_year = @s_fiscalyear
                  AND calendar_periods.period_start_date <= @dt_recvddate
                  AND calendar_periods.period_end_date >= @dt_recvddate
                  AND Charindex('close', Lower(calendar_periods.period_name)) = 0 
                  AND Charindex('closing', Lower(calendar_periods.period_name)) = 0
                  AND Charindex('begin', Lower(calendar_periods.period_name)) = 0 
                  AND Charindex('open', Lower(calendar_periods.period_name)) = 0

               IF @s_exponreceipt = 'Y'
                BEGIN
                 -- If the user is not expensing on receipt, we don't need
                 -- an RNI account.
                 IF @s_draccounttable = 'Inventory Accounts'
                  BEGIN
                   -- Get the RNI account from Monitor Inventory Accounts
                   IF @s_accountstyle = 'Account'
                    BEGIN
                     -- Need the GL Segment for the Plant
                     SELECT @s_plantaccount = RTrim(IsNull(gl_segment,''))
                       FROM destination
                      WHERE destination = @s_plant
                     IF @@rowcount = 0 SELECT @s_plantaccount = ''
                    END
                   ELSE
                    BEGIN
                     -- Don't need a plant GL segment
                     SELECT @s_plantaccount = ''
                    END

                   -- Need the part type and the product line to do the lookup
                   -- into monitor_inventory_accounts
                   SELECT @s_parttype = IsNull(part.type,'R'),
                          @s_productline = IsNull(product_line, '')
                     FROM part
                    WHERE part = @s_part
                   IF @@rowcount = 0
                    BEGIN
                     -- didn't find the part. Assume its a raw material since
                     -- that's what's most likely to be received.
                     SELECT @s_parttype = 'R'
                     SELECT @s_productline = ''
                     SELECT @s_productlineaccount = ''
                    END
                   ELSE
                    BEGIN
                     -- found the part. Do we need the product line segment?
                     IF @s_accountstyle = 'Account'
                      BEGIN
                       -- Need the GL Segment for the product line
                       SELECT @s_productlineaccount = IsNull(gl_segment,'') 
                         FROM product_line
                        WHERE product_line.id = @s_productline
                       IF @@rowcount = 0 SELECT @s_productlineaccount = ''
                      END
                     ELSE
                      BEGIN
                       -- Don't need a product line GL segment
                       SELECT @s_productlineaccount = ''
                      END
                    -- end found the part
                    END

                   -- Now get the RNI account for the product line. 
                   SELECT @s_rniaccount = RTrim(IsNull(material_credit,''))
                     FROM monitor_inventory_accounts
                    WHERE fiscal_year = @s_fiscalyear 
                      AND ledger = @s_ledger
                      AND product_line = @s_productline
                      AND audit_trail_type = 'R'
                      AND part_type = @s_parttype
                   IF @@rowcount = 0 SELECT @s_rniaccount = ''

                   SELECT @s_rniledgeraccount = @s_rniaccount + @s_plantaccount + @s_productlineaccount
                  -- end using monitor_inventory_accounts
                  END
                 ELSE
                  BEGIN
                   -- Not using monitor_inventory_accounts. Get the RNI 
                   -- ledger account from the vendor table
                   SELECT @s_rniledgeraccount = IsNull(item_rni_ledger_account,'')
                     FROM vendors
                    WHERE vendor = @s_vendor
                   IF @@rowcount = 0 SELECT @s_rniledgeraccount = ''
                  -- end not using monitor_inventory_accounts
                  END
                -- end PO was expensed on receipt
                END
               ELSE
                BEGIN
                 --Expense on receipt is 'N'. Don't need an RNI account.
                 SELECT @s_rniledgeraccount = ''
                END

               -- Have everything we need to create the receiver header.
               INSERT INTO po_receivers
                  (purchase_order, bill_of_lading, location,
                   clerk, freight_carrier, ledger_account_code,
                   fiscal_year, ledger, gl_entry, period,
                   gl_date, received_date, 
                   changed_date, changed_user_id)
                 VALUES
                  (@s_ponumber, @s_shipper, @s_plant,
                   '', '', @s_rniledgeraccount,
                   @s_fiscalyear, @s_ledger, '', @i_period,
                   @dt_recvddate, @dt_recvddate,
                   GetDate(), 'MONITOR') 

               IF @s_exponreceipt = 'Y'
                BEGIN
                 -- Now insert the corresponding gl_cost_transactions.

                 -- First, the credit to the RNI account.
                 INSERT INTO gl_cost_transactions
                    (document_type, document_id1, document_id2,
                     document_id3, document_line,ledger_account,
                     contract_id, contract_account_id, costrevenue_type_id,
                     fiscal_year, ledger, gl_entry,
                     period, transaction_date, amount,
                     document_amount, document_currency, exchange_date,
                     exchange_rate, document_reference1, document_reference2,
                     document_remarks, application, quantity,
                     unit_of_measure, user_defined_text, user_defined_number,
                     user_defined_date, changed_date, changed_user_id,
                     update_balances)
                   VALUES 
                    ('BILL OF LADING', @s_ponumber, @s_shipper,
                     '',0,@s_rniledgeraccount,
                     '','','',
                     @s_fiscalyear,@s_ledger,'',
                     @i_period,@dt_recvddate,(@c_amount * -1.0),
                     (@c_amount * -1.0),@s_currency,@dt_recvddate,
                     1,@s_vendor,@s_vendorname,
                     '','PO',0,
                     '','',0,
                     NULL,GetDate(),'MONITOR',
                     'N')
                -- expense on receipt is 'Y'
                END
              -- didn't have a receiver header
              END

             -- all set on the PO receiver header. Need to write a PO
             -- receiver item. First, get the ledger account for this item
	     -- from the PO item. The ledger account on the PO item will have
             -- come from either Inventory Accounts or PO Detail.
             SELECT @s_itemledgeraccount = '' 
             SELECT @s_itemledgeraccount = ledger_account_code
               FROM po_items
              WHERE purchase_order = @s_ponumber
                AND item = @s_part
             IF @@rowcount = 0 SELECT @s_itemledgeraccount = '' 

             -- Next, get the PO line for this item.
             SELECT @i_bolline = po_line,
                    @s_partdesc = Convert(char(250),item_description)
               FROM po_items
              WHERE purchase_order = @s_ponumber
                AND item = @s_part

             IF @@rowcount > 0 AND @i_bolline > 0
              BEGIN
               -- What to do if we don't find this item on the PO?
 
               -- Next, get a receiver. We'll hope that no one 
               -- gets this receiver before our modification gets updated.
               EXECUTE GetNextIdentifier 'PO RECEIVER', 
                                         'PO RECEIVER',
                                         @s_receiver OUTPUT

               -- Insert a row into the PO receiver items table        
               INSERT INTO po_receiver_items
                  (purchase_order, bill_of_lading, bol_line,
                   receiver, invoice, inv_line,
                   item, item_description, approved, receiver_comments,
                   ledger_account_code, 
                   quantity_received, unit_cost,
                   changed_date, changed_user_id, total_cost)
                 VALUES
                  (@s_ponumber, @s_shipper, @i_bolline,
                   @s_receiver, '', 0,
                   @s_part, @s_partdesc, 'Y', '',
                   @s_itemledgeraccount,
                   @c_quantity, @c_cost,
                   GetDate(), 'MONITOR', @c_amount)

               IF @s_exponreceipt = 'Y'
                BEGIN
                 -- Now debit the expense account.
                 INSERT INTO gl_cost_transactions
                    (document_type, document_id1, document_id2,
                     document_id3, document_line,
                     ledger_account,
                     contract_id, contract_account_id, costrevenue_type_id,
                     fiscal_year, ledger, gl_entry,
                     period, transaction_date, amount,
                     document_amount, document_currency, exchange_date,
                     exchange_rate, document_reference1, document_reference2,
                     document_remarks, application, quantity,
                     unit_of_measure, user_defined_text, user_defined_number,
                     user_defined_date, changed_date, changed_user_id,
                     update_balances)
                   VALUES 
                    ('BILL OF LADING', @s_ponumber, @s_shipper,
                     '',@i_bolline,
                     @s_itemledgeraccount,
                     '','','',
                     @s_fiscalyear,@s_ledger,'',
                     @i_period,@dt_recvddate,@c_amount ,
                     @c_amount,@s_currency,@dt_recvddate,
                     1,@s_vendor,@s_vendorname,
                     @s_partdesc,'PO',@c_quantity,
                     '','',0,
                     NULL,GetDate(),'MONITOR',
                     'N')
                END
              -- end found the item on the PO
              END
            -- end needed to create the PO receiver item
            END

           IF @s_havehdr = 'Y' AND @s_exponreceipt = 'Y' AND @s_invoice = ''
            BEGIN
             -- still need to update the GL cost transactions for the header.
             -- it carries a credit balance, so subtract the amount.
             UPDATE gl_cost_transactions
                SET amount = amount - @c_amount,
                    document_amount = document_amount - @c_amount, 
                    changed_date = GetDate(), 
                    changed_user_id = 'MONITOR'
              WHERE document_type = 'BILL OF LADING' AND
                    document_id1 = @s_ponumber AND
                    document_id2 = @s_shipper AND
                    document_id3 = '' AND
                    document_line = 0
            END
         -- end audit_trail quantity > 0
         END
        ELSE
         BEGIN
         -- audit_trail quantity <= 0
           -- Get the datestamp for the positive receiver audit_trail row for this serial
           -- and call the stored procedure to correct the existing Empower receiver.
           -- Should only be one row but we'll use max just in case.
           SELECT @dt_prevdatestamp = Max(date_stamp)
             FROM audit_trail
            WHERE serial = @i_serial
              AND type = 'R'
              AND quantity > 0
           IF @@rowcount > 0
             BEGIN
               EXECUTE CorrectEmpowerReceiver
                       @s_ponumber,
                       @s_shipper,
                       @s_part,
                       @c_quantity,
                       @dt_prevdatestamp
             END
         -- end audit_trail quantity <= 0
         END
      -- end audit_trail type is 'R'
      END
     ELSE
      BEGIN
       -- This is an audit_trail type other than an 'R'. If it is an
       -- X (correct) or a D (delete), we need to determine if this correct 
       -- or delete is associated with a receipt. If it is, we need to 
       -- correct the quantity on po_receiver_items.
       IF (@s_type = 'X' OR (@s_type = 'D' AND @s_remarks <> 'Scrap')) AND
           @s_deletecorrectreceipts = 'Y'
        BEGIN
         -- Get the prior audit_trail row for this serial.
         SELECT @s_prevtype = type, 
                @s_prevponumber = LTrim(RTrim(IsNull(po_number,''))),
                @s_prevshipper = LTrim(RTrim(Upper(IsNull(shipper,'')))), 
                @s_prevpart = IsNull(part,''),
                @c_prevquantity = IsNull(quantity,0),
                @c_prevstdquantity = IsNull(std_quantity,0),
                @dt_prevdatestamp = date_stamp
           FROM audit_trail
          WHERE serial = @i_serial
            AND date_stamp = (SELECT max(date_stamp) FROM audit_trail
                               WHERE serial = @i_serial
                                 AND date_stamp < @dt_datestamp
                                 AND type <> 'T')
         IF @s_type = 'D'
          BEGIN
           -- Empire has D transactions following Y (Empire scrap)
           -- transactions. Both the D and the Y have the same time
           -- stamp. If we can find a 'Y' with the same time stamp
           -- as the D, then the previous transaction type was Y.
           SELECT @i_count = Count(*) 
             FROM audit_trail
            WHERE serial = @i_serial
              AND date_stamp = @dt_datestamp
              AND type = 'Y'
           IF @i_count > 0 SELECT @s_prevtype = 'Y'
          END 
         IF @s_prevtype = 'X'
          BEGIN
           -- Are deleting or correcting a previous correction. We need
           -- the quantity from it, but we need the other info from a
           -- row that's not a correction. 
           SELECT @s_prevtype = type, 
                  @s_prevponumber = LTrim(RTrim(IsNull(po_number,''))),
                  @s_prevshipper = LTrim(RTrim(Upper(IsNull(shipper,'')))), 
                  @s_prevpart = IsNull(part,''),
                  @dt_prevdatestamp = date_stamp
             FROM audit_trail
            WHERE serial = @i_serial
              AND date_stamp = (SELECT max(date_stamp) FROM audit_trail
                                WHERE serial = @i_serial
                                  AND date_stamp < @dt_datestamp
                                  AND type NOT IN ('X','T'))
          END
         IF @s_prevtype = 'R'
          BEGIN
           -- no work to do if the previous audit_trail type isn't an 'R'.
           -- There is a stored procedure that handles the deletion of an
           -- 'R'. They way it is written will also allow it to handle a
           -- change in quantity on an 'R', so we'll simply call it with
           -- the correct quantity.
           IF @s_usestdcost = 'Y' SELECT @c_prevquantity = @c_prevstdquantity
           IF @s_type = 'X'
            BEGIN
             IF @s_usestdcost = 'Y' SELECT @c_quantity = @c_stdquantity
             SELECT @c_quantitychg = @c_quantity - @c_prevquantity
            END
           ELSE
            BEGIN
             -- there has been discussion about whether the quantity on
             -- a delete will be 0 or the deleted quantity. We won't count
             -- on the value from the delete but will use the value from
             -- the original receipt or previous correction.
             SELECT @c_quantitychg = 0 - @c_prevquantity
            END
           EXECUTE CorrectEmpowerReceiver
                   @s_prevponumber,
                   @s_prevshipper,
                   @s_prevpart,
                   @c_quantitychg,
                   @dt_prevdatestamp
          -- end X or D related to an R
          END
        -- end X or D
        END
      -- end not an R 
      END
    -- end loop
    END
  CLOSE insauditcursor
  DEALLOCATE insauditcursor
 -- end have rows in the inserted table
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

CREATE TRIGGER [dbo].[Update_AuditTrailMonitor]
ON [dbo].[audit_trail] FOR UPDATE
AS

-- 17-Apr-08 Removed references to preferences_site.

-- 09-Apr-04 Use the quantity, not the std_quantity, when the preference
--           MonitorStandardCost is 'N'.

-- 02-Mar-2004 Created from SQLAnywhere version.

IF update(type)
 BEGIN
  DECLARE @s_posted   char(1),
          @s_oldtype  varchar(2),
          @s_newtype  varchar(2),
          @s_shipper  varchar(20),
          @s_ponumber varchar(25),
          @s_part     varchar(25),
          @c_quantity numeric(18,6),
          @c_stdquantity numeric(18,6),
          @i_rowcount int,
          @dt_datestamp datetime,
          @s_usestdcost char(1)

  -- Make sure that we have a row in the inserted table for processing
  SELECT @i_rowcount = Count(*) FROM inserted

  IF @i_rowcount > 0
    BEGIN
     -- Get the preference that indicates if standard or actual cost
     -- should be used.
     SELECT @s_usestdcost = IsNull(value,'')
       FROM preferences_standard
      WHERE preference = 'MonitorStandardCost'
     IF @@rowcount = 0 OR @s_usestdcost = '' SELECT @s_usestdcost = 'Y'

      -- To eliminate duplicate code, use a cursor whether one or multiple
      -- rows are deleted.
      DECLARE updauditcursor CURSOR FOR
       SELECT IsNull(deleted.posted,'N'),
              IsNull(deleted.type,''), 
              IsNull(inserted.type,''), 
              LTrim(RTrim(IsNull(deleted.shipper,''))),
              LTrim(RTrim(IsNull(deleted.po_number,''))), 
              IsNull(deleted.part,''), 
              IsNull(deleted.quantity,0),
              IsNull(deleted.std_quantity,0),
              deleted.date_stamp 
         FROM deleted, inserted
        WHERE deleted.serial = inserted.serial
          AND deleted.date_stamp = inserted.date_stamp

      OPEN updauditcursor

      WHILE 1 = 1
        BEGIN
          FETCH updauditcursor 
           INTO @s_posted, @s_oldtype, @s_newtype, @s_shipper, @s_ponumber,
                @s_part, @c_quantity, @c_stdquantity, @dt_datestamp

          IF @@fetch_status <> 0 BREAK

          -- Don't allow a row to be deleted if it's gone to GL.
          IF @s_newtype = 'D' AND @s_posted = 'Y' 
            --RAISERROR('Transactions interfaced to Empower GL cannot be deleted.',11,1)
            RAISERROR('Deleting a transaction interfaced to Empower GL.',11,1)
          ELSE
           BEGIN
            IF @s_oldtype = 'R' AND @s_newtype = 'D'
             BEGIN
              -- Update the Empower receiver for this audit trail delete.
              IF @s_usestdcost = 'Y' SELECT @c_quantity = @c_stdquantity
              SELECT @c_quantity = 0 - @c_quantity
              EXECUTE CorrectEmpowerReceiver @s_ponumber,
                                             @s_shipper,
                                             @s_part,
                                             @c_quantity,
                                             @dt_datestamp
             END
           END
        END

      CLOSE updauditcursor
      DEALLOCATE updauditcursor
   END
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
CREATE NONCLUSTERED INDEX [ix_AuditTrail_PO] ON [dbo].[audit_trail] ([type], [po_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [audit_trail_workorder_ix] ON [dbo].[audit_trail] ([workorder]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [workorder_type] ON [dbo].[audit_trail] ([workorder], [type]) ON [PRIMARY]
GO
