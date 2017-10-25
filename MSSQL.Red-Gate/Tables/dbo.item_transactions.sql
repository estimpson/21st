CREATE TABLE [dbo].[item_transactions]
(
[item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serial_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_date] [datetime] NULL,
[gl_entry] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fiscal_year] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period] [smallint] NULL,
[transaction_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [decimal] (18, 6) NULL,
[amount] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[debit_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[credit_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[batch] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_id3] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_line] [smallint] NOT NULL,
[container_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country_of_origin] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_cost] [decimal] (18, 6) NULL,
[transfer_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_production_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_ItemTransactions]
ON [dbo].[item_transactions] FOR DELETE
AS

-- 01-Nov-05 1. Modified to get the preference value for IVStandardCosting.
--              When standard costing is in effect, update the average cost
--              with the item location mimimum_average_cost which is also
--              as the standard cost.
--           2. When the on-hand quantity es to zero, set the average cost
--              to zero.

-- 12-Apr-02 No longer set the average cost to zero when the on-hand
--           quantity goes to zero.

-- 18-Feb-02 Handle RETURNS like RECEIPTS.

  BEGIN
    DECLARE @c_onhandquantity dec(18,6),
            @s_item varchar(50),
            @s_location varchar(25),
            @s_serial varchar(50),
            @s_transtype varchar(25),
            @s_changeduserid varchar(25),
            @c_quantity dec(18,6),
            @c_amount dec(18,6),
            @s_stdcosting CHAR(1),
            @i_rowcount int

  /*  Make sure that we have a row in the deleted table for processing */
  SELECT @i_rowcount = Count(*) FROM deleted

  IF @i_rowcount > 0
    BEGIN
      -- Get the preference that indicates if standard or actual cost
      -- should be used.
      SELECT @s_stdcosting = IsNull(value,'')
        FROM preferences_site
       WHERE preference = 'IVStandardCosting'

      IF @@rowcount = 0 OR @s_stdcosting = ''
        BEGIN
         SELECT @s_stdcosting = IsNull(value,'')
           FROM preferences_standard
          WHERE preference = 'IVStandardCosting'
         IF @@rowcount = 0 OR @s_stdcosting = '' SELECT @s_stdcosting = 'N'
        END

      DECLARE delitemtranscursor CURSOR FOR
        SELECT deleted.item,
               deleted.location,
               deleted.serial_number,
               deleted.transaction_type,
               IsNull(deleted.amount,0),
               IsNull(deleted.quantity,0),
               deleted.changed_user_id
          FROM deleted

        OPEN delitemtranscursor

        WHILE 1 = 1
          BEGIN
            FETCH delitemtranscursor
             INTO @s_item,
                  @s_location,
                  @s_serial,
                  @s_transtype,
                  @c_amount,
                  @c_quantity,
                  @s_changeduserid

            /* any status from the fetch other than 0 will terminate the
               loop. */
            IF @@fetch_status <> 0 BREAK

            -- determine if a row exists in the item serial table.
            -- it always should.
            SELECT @c_onhandquantity = on_hand_quantity
              FROM item_serial
             WHERE item = @s_item AND
                   location = @s_location AND
                   serial_number = @s_serial

            IF @@rowcount > 0
              BEGIN
                -- row found, so update it
                IF @s_transtype IN ('RECEIPT','ADJ IN','XFER IN','RETURN')
                  BEGIN
                     -- subtract amounts
                     UPDATE item_serial
                        SET on_hand_quantity = on_hand_quantity - @c_quantity,
                            inventory_amount = inventory_amount - @c_amount,
                            changed_date = GetDate(),
                            changed_user_id = @s_changeduserid
                      WHERE item = @s_item AND
                            location = @s_location AND
                            serial_number = @s_serial

                  END
                ELSE
                  BEGIN
                     -- add amounts
                     UPDATE item_serial
                        SET on_hand_quantity = on_hand_quantity + @c_quantity,
                            inventory_amount = inventory_amount + @c_amount,
                            changed_date = GetDate(),
                            changed_user_id = @s_changeduserid
                      WHERE item = @s_item AND
                            location = @s_location AND
                            serial_number = @s_serial

                  END

                IF @s_stdcosting = 'N'
                  BEGIN
                    -- update the average cost being careful not to divide
                    -- by zero.
                    UPDATE item_serial
                       SET average_cost =
                             Round(inventory_amount / on_hand_quantity, 5)
                     WHERE item = @s_item AND
                           location = @s_location AND
                           serial_number = @s_serial AND
                           on_hand_quantity <> 0

                    UPDATE item_serial
                       SET average_cost = 0
                     WHERE item = @s_item AND
                           location = @s_location AND
                           serial_number = @s_serial AND
                           on_hand_quantity = 0
                  END
                ELSE
                  BEGIN
                    -- Using standard costing.  Make sure the average cost
                    -- is the "standard cost".
                    UPDATE item_serial
                       SET average_cost =
                          (SELECT IsNull(minimum_ave_cost,0)
                             FROM item_locations
                            WHERE item_locations.item = @s_item
                              AND item_locations.location = @s_location )
                     WHERE item = @s_item AND
                           location = @s_location AND
                           serial_number = @s_serial
                  END

              END
          END

          CLOSE delitemtranscursor
          DEALLOCATE delitemtranscursor

    END
  END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_ItemTransactions]
ON [dbo].[item_transactions] FOR INSERT
AS

-- 01-Nov-05 1. Modified to get the preference value for IVStandardCosting.
--              When standard costing is in effect, update the average cost
--              with the item location mimimum_average_cost which is also
--              as the standard cost.
--           2. When the on-hand quantity goes to zero, set the average cost
--              to zero.

-- 07-Sep-05 When inserting a new item_serial row, check for quantity of zero when
--           computing average cost.

-- 12-Apr-02 No longer set the average cost to zero when the on-hand
--           quantity goes to zero.

-- 18-Feb-02 Handle RETURNS like RECEIPTS.

  BEGIN
    DECLARE @c_onhandquantity dec(18,6),
            @s_item varchar(50),
            @s_location varchar(25),
            @s_serial varchar(50),
            @s_transtype varchar(25),
            @s_changeduserid varchar(25),
            @s_containerid varchar(25),
            @s_package varchar(25),
            @s_countryoforigin varchar(25),
            @c_quantity dec(18,6),
            @c_amount dec(18,6),
            @c_averagecost dec(18,6),
            @s_stdcosting CHAR(1),
            @i_rowcount int

  /*  Make sure that we have a row in the inserted table for processing */
  SELECT @i_rowcount = Count(*) FROM inserted

  IF @i_rowcount > 0
    BEGIN

      -- Get the preference that indicates if standard or actual cost
      -- should be used.
      SELECT @s_stdcosting = IsNull(value,'')
        FROM preferences_site
       WHERE preference = 'IVStandardCosting'

      IF @@rowcount = 0 OR @s_stdcosting = ''
        BEGIN
         SELECT @s_stdcosting = IsNull(value,'')
           FROM preferences_standard
          WHERE preference = 'IVStandardCosting'
         IF @@rowcount = 0 OR @s_stdcosting = '' SELECT @s_stdcosting = 'N'
        END

      DECLARE insitemtranscursor CURSOR FOR
        SELECT inserted.item,
               inserted.location,
               inserted.serial_number,
               inserted.transaction_type,
               IsNull(inserted.amount,0),
               IsNull(inserted.quantity,0),
               IsNull(inserted.container_id,''),
               IsNull(inserted.package,''),
               IsNull(inserted.country_of_origin,''),
               inserted.changed_user_id
          FROM inserted

        OPEN insitemtranscursor

        WHILE 1 = 1
          BEGIN
            FETCH insitemtranscursor
             INTO @s_item,
                  @s_location,
                  @s_serial,
                  @s_transtype,
                  @c_amount,
                  @c_quantity,
                  @s_containerid,
                  @s_package,
                  @s_countryoforigin,
                  @s_changeduserid

            /* any status from the fetch other than 0 will terminate the
               loop. */
            IF @@fetch_status <> 0 BREAK

            -- determine if a row exists in the item serial table
            SELECT @c_onhandquantity = on_hand_quantity
              FROM item_serial
             WHERE item = @s_item AND
                   location = @s_location AND
                   serial_number = @s_serial

            IF @@rowcount > 0
              BEGIN
                -- row found, so update it
                IF @s_transtype IN ('RECEIPT','ADJ IN','XFER IN','RETURN')
                  BEGIN
                     -- add amounts
                     UPDATE item_serial
                        SET on_hand_quantity = on_hand_quantity + @c_quantity,
                            inventory_amount = inventory_amount + @c_amount,
                            changed_date = GetDate(),
                            changed_user_id = @s_changeduserid
                      WHERE item = @s_item AND
                            location = @s_location AND
                            serial_number = @s_serial
                  END
                ELSE
                  BEGIN
                     -- subtract amounts
                     UPDATE item_serial
                        SET on_hand_quantity = on_hand_quantity - @c_quantity,
                            inventory_amount = inventory_amount - @c_amount,
                            changed_date = GetDate(),
                            changed_user_id = @s_changeduserid
                      WHERE item = @s_item AND
                            location = @s_location AND
                            serial_number = @s_serial
                  END

                IF @s_stdcosting = 'N'
                  BEGIN
                    -- update the average cost being careful not to divide
                    -- by zero.
                    UPDATE item_serial
                       SET average_cost =
                             Round(inventory_amount / on_hand_quantity, 5)
                     WHERE item = @s_item AND
                           location = @s_location AND
                           serial_number = @s_serial AND
                           on_hand_quantity <> 0

                    UPDATE item_serial
                       SET average_cost = 0
                     WHERE item = @s_item AND
                           location = @s_location AND
                           serial_number = @s_serial AND
                           on_hand_quantity = 0
                  END
                ELSE
                  BEGIN
                    -- Using standard costing.  Make sure the average cost
                    -- is the "standard cost".
                    UPDATE item_serial
                       SET average_cost =
                          (SELECT IsNull(minimum_ave_cost,0)
                             FROM item_locations
                            WHERE item_locations.item = @s_item
                              AND item_locations.location = @s_location )
                     WHERE item = @s_item AND
                           location = @s_location AND
                           serial_number = @s_serial
                  END
              END
            ELSE
              BEGIN
                IF @s_stdcosting = 'N'
                  BEGIN
                    IF @c_quantity = 0
                      BEGIN
                        SELECT @c_averagecost = 0
                      END
                    ELSE
                      BEGIN
                        SELECT @c_averagecost = Round(@c_amount / @c_quantity, 5)
                      END
                  END
                ELSE
                  BEGIN
                    -- Using standard costing.  Make sure the average cost
                    -- is the "standard cost".
                    SELECT @c_averagecost = IsNull(minimum_ave_cost,0)
                      FROM item_locations
                     WHERE item_locations.item = @s_item
                       AND item_locations.location = @s_location
                  END

                -- row not found, so insert it
                IF @s_transtype IN ('RECEIPT','ADJ IN','XFER IN','RETURN')
                  BEGIN
                     -- amounts are positive
                     INSERT INTO item_serial
                                (item, location, serial_number, on_hand_quantity,
                                 sold_quantity, reserved_quantity, inventory_amount,
                                 average_cost, changed_date, changed_user_id,
                                 container_id, package, country_of_origin )
                         VALUES (@s_item, @s_location, @s_serial,
                                 @c_quantity, 0, 0, @c_amount,
                                 @c_averagecost,
                                 GetDate(), @s_changeduserid,
                                 @s_containerid, @s_package,
                                 @s_countryoforigin )
                  END
                ELSE
                  BEGIN
                    -- amounts are negative
                    INSERT INTO item_serial
                               (item, location, serial_number, on_hand_quantity,
                                sold_quantity, reserved_quantity, inventory_amount,
                                average_cost, changed_date, changed_user_id,
                                container_id, package, country_of_origin )
                         VALUES (@s_item, @s_location, @s_serial,
                                 @c_quantity * -1, 0, 0, @c_amount * -1,
                                 @c_averagecost,
                                 GetDate(), @s_changeduserid,
                                 @s_containerid, @s_package,
                                 @s_countryoforigin )
                  END
              END
          END

          CLOSE insitemtranscursor
          DEALLOCATE insitemtranscursor

    END
  END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_ItemTransactions]
ON [dbo].[item_transactions] FOR UPDATE
AS

-- 02-Nov-05 1. Modified to get the preference value for IVStandardCosting.
--              When standard costing is in effect, update the average cost
--              with the item location mimimum_average_cost which is also
--              as the standard cost.
--           2. When the on-hand quantity goes to zero, set the average cost
--              to zero.

-- 07-Sep-05 When inserting a new item_serial row, check for quantity of zero when
--           computing average cost.

-- 01-Oct-02 Update the item_serial country of origin, container ID,
--           and package.

-- 12-Apr-02 No longer set the average cost to zero when the on-hand
--           quantity goes to zero.

-- 25-Feb-02 Join inserted to deleted on the primary key. Previously,
--           the join had no where clause.

-- 18-Feb-02 Handle RETURNS like RECEIPTS.

IF update(transaction_type) OR update(item) OR update(location) OR
   update(serial_number) OR update(amount) OR update(quantity) OR
   update(country_of_origin) OR update(container_id) OR update(package)

  BEGIN
    DECLARE @c_onhandquantity decimal(18,6),
            @s_newitem varchar(50),
            @s_olditem varchar(50),
            @s_newlocation varchar(25),
            @s_oldlocation varchar(25),
            @s_newserial varchar(50),
            @s_oldserial varchar(50),
            @s_newtranstype varchar(25),
            @s_oldtranstype varchar(25),
            @s_newchangeduserid varchar(25),
            @s_oldchangeduserid varchar(25),
            @s_newcontainerid varchar(25),
            @s_newpackage varchar(25),
            @s_newcountryoforigin varchar(25),
            @c_newquantity dec(18,6),
            @c_oldquantity dec(18,6),
            @c_newamount dec(18,6),
            @c_oldamount dec(18,6),
            @c_averagecost dec(18,6),
            @s_stdcosting CHAR(1),
            @i_rowcount int

  /*  Make sure that we have a row in the inserted table for processing */
  SELECT @i_rowcount = Count(*) FROM inserted

  IF @i_rowcount > 0
    BEGIN

      -- Get the preference that indicates if standard or actual cost
      -- should be used.
      SELECT @s_stdcosting = IsNull(value,'')
        FROM preferences_site
       WHERE preference = 'IVStandardCosting'

      IF @@rowcount = 0 OR @s_stdcosting = ''
        BEGIN
         SELECT @s_stdcosting = IsNull(value,'')
           FROM preferences_standard
          WHERE preference = 'IVStandardCosting'
         IF @@rowcount = 0 OR @s_stdcosting = '' SELECT @s_stdcosting = 'N'
        END

      DECLARE upditemtranscursor CURSOR FOR
        SELECT deleted.item,
               inserted.item,
               deleted.location,
               inserted.location,
               deleted.serial_number,
               inserted.serial_number,
               deleted.transaction_type,
               inserted.transaction_type,
               IsNull(deleted.amount,0),
               IsNull(inserted.amount,0),
               IsNull(deleted.quantity,0),
               IsNull(inserted.quantity,0),
               IsNull(inserted.container_id,''),
               IsNull(inserted.package,''),
               IsNull(inserted.country_of_origin,''),
               deleted.changed_user_id,
               inserted.changed_user_id
          FROM inserted, deleted
         WHERE inserted.document_type = deleted.document_type AND
               inserted.document_id1 = deleted.document_id1 AND
               inserted.document_id2 = deleted.document_id2 AND
               inserted.document_id3 = deleted.document_id3 AND
               inserted.document_line = deleted.document_line

        OPEN upditemtranscursor

        WHILE 1 = 1
          BEGIN
            FETCH upditemtranscursor
             INTO @s_olditem,
                  @s_newitem,
                  @s_oldlocation,
                  @s_newlocation,
                  @s_oldserial,
                  @s_newserial,
                  @s_oldtranstype,
                  @s_newtranstype,
                  @c_oldamount,
                  @c_newamount,
                  @c_oldquantity,
                  @c_newquantity,
                  @s_newcontainerid,
                  @s_newpackage,
                  @s_newcountryoforigin,
                  @s_oldchangeduserid,
                  @s_newchangeduserid

            /* any status from the fetch other than 0 will terminate the
               loop. */
            IF @@fetch_status <> 0 BREAK

            --  Since its possible to change the transaction type and/or any or all
            --  of the key fields, the best thing to do is to back out the old
            --  transaction and then add in the new one.
            -- first back out the old transaction...
            IF @s_oldtranstype IN ('RECEIPT','ADJ IN','XFER IN','RETURN')
              BEGIN
                -- subtract the old amounts out
                UPDATE item_serial
                   SET on_hand_quantity = on_hand_quantity - @c_oldquantity,
                       inventory_amount = inventory_amount - @c_oldamount,
                       changed_date = GetDate(),
                       changed_user_id = @s_oldchangeduserid
                 WHERE item = @s_olditem AND
                       location = @s_oldlocation AND
                       serial_number = @s_oldserial
              END
            ELSE
              BEGIN
                -- must have been an ISSUE, ADJ OUT or XFER OUT so add the
                -- old amounts back in
                UPDATE item_serial
                   SET on_hand_quantity = on_hand_quantity + @c_oldquantity,
                       inventory_amount = inventory_amount + @c_oldamount,
                       changed_date = GetDate(),
                       changed_user_id = @s_oldchangeduserid
                 WHERE item = @s_olditem AND
                       location = @s_oldlocation AND
                       serial_number = @s_oldserial
              END

            IF @s_stdcosting = 'N'
              BEGIN
                -- update the old average cost being careful not to divide
                -- by zero.
                UPDATE item_serial
                   SET average_cost =
                         Round(inventory_amount / on_hand_quantity, 5)
                 WHERE item = @s_olditem AND
                       location = @s_oldlocation AND
                       serial_number = @s_oldserial AND
                       on_hand_quantity <> 0

                UPDATE item_serial
                   SET average_cost = 0
                 WHERE item = @s_olditem AND
                       location = @s_oldlocation AND
                       serial_number = @s_oldserial AND
                       on_hand_quantity = 0
              END
            ELSE
              BEGIN
                -- Using standard costing.  Make sure the average cost
                -- is the "standard cost".
                UPDATE item_serial
                   SET average_cost =
                      (SELECT IsNull(minimum_ave_cost,0)
                         FROM item_locations
                        WHERE item_locations.item = @s_olditem
                          AND item_locations.location = @s_oldlocation )
                 WHERE item = @s_olditem AND
                       location = @s_oldlocation AND
                       serial_number = @s_oldserial
              END

            -- then add in the new transaction...
            -- first need to find out if a row exists for the new transaction
            -- in the item serial table
            SELECT @c_onhandquantity = on_hand_quantity
              FROM item_serial
             WHERE item = @s_newitem AND
                   location = @s_newlocation AND
                   serial_number = @s_newserial

            IF @@rowcount > 0
              BEGIN
                -- update the existing row
                IF @s_newtranstype IN ('RECEIPT','ADJ IN','XFER IN','RETURN')
                  BEGIN
                    -- add the amounts
                    UPDATE item_serial
                       SET on_hand_quantity = on_hand_quantity + @c_newquantity,
                           inventory_amount = inventory_amount + @c_newamount,
                           changed_date = GetDate(),
                           changed_user_id = @s_newchangeduserid
                     WHERE item = @s_newitem AND
                           location = @s_newlocation AND
                           serial_number = @s_newserial
                  END
                ELSE
                  BEGIN
                    -- subtract the amounts
                    UPDATE item_serial
                       SET on_hand_quantity = on_hand_quantity - @c_newquantity,
                           inventory_amount = inventory_amount - @c_newamount,
                           changed_date = GetDate(),
                           changed_user_id = @s_newchangeduserid
                     WHERE item = @s_newitem AND
                           location = @s_newlocation AND
                           serial_number = @s_newserial
                  END

                IF @s_stdcosting = 'N'
                  BEGIN
                    -- update the new average cost being careful not to divide
                    -- by zero.
                    UPDATE item_serial
                       SET average_cost =
                             Round(inventory_amount / on_hand_quantity, 5)
                     WHERE item = @s_newitem AND
                           location = @s_newlocation AND
                           serial_number = @s_newserial AND
                        on_hand_quantity <> 0

                    UPDATE item_serial
                       SET average_cost = 0
                     WHERE item = @s_newitem AND
                           location = @s_newlocation AND
                           serial_number = @s_newserial AND
                        on_hand_quantity = 0
                  END
                ELSE
                  BEGIN
                    -- Using standard costing.  Make sure the average cost
                    -- is the "standard cost".
                    UPDATE item_serial
                       SET average_cost =
                          (SELECT IsNull(minimum_ave_cost,0)
                             FROM item_locations
                            WHERE item_locations.item = @s_newitem
                              AND item_locations.location = @s_newlocation )
                     WHERE item = @s_newitem AND
                           location = @s_newlocation AND
                           serial_number = @s_newserial
                  END

                -- update the country of origin, container ID, and
                -- package.
                UPDATE item_serial
                   SET container_id = @s_newcontainerid,
                       package = @s_newpackage,
                       country_of_origin = @s_newcountryoforigin
                 WHERE item = @s_newitem AND
                       location = @s_newlocation AND
                       serial_number = @s_newserial

              END
            ELSE
              BEGIN
                IF @s_stdcosting = 'N'
                  BEGIN
                    IF @c_newquantity = 0
                      BEGIN
                        SELECT @c_averagecost = 0
                      END
                    ELSE
                      BEGIN
                        SELECT @c_averagecost = Round(@c_newamount / @c_newquantity, 5)
                      END
                  END
                ELSE
                  BEGIN
                    -- Using standard costing.  Make sure the average cost
                    -- is the "standard cost".
                    SELECT @c_averagecost = IsNull(minimum_ave_cost,0)
                      FROM item_locations
                     WHERE item_locations.item = @s_newitem
                       AND item_locations.location = @s_newlocation
                  END

                -- insert a new row
                IF @s_newtranstype IN ('RECEIPT','ADJ IN','XFER IN','RETURN')
                  BEGIN
                    -- amounts are positive
                    INSERT INTO item_serial
                       (item, location, serial_number, on_hand_quantity,
                        sold_quantity, reserved_quantity, inventory_amount,
                        average_cost, changed_date, changed_user_id,
                        container_id, package, country_of_origin )
                    VALUES (@s_newitem, @s_newlocation, @s_newserial,
                            @c_newquantity, 0, 0, @c_newamount,
                            @c_averagecost,
                            GetDate(), @s_newchangeduserid,
                            @s_newcontainerid, @s_newpackage,
                            @s_newcountryoforigin )
                  END
                ELSE
                  BEGIN
                    -- amounts are negative
                    INSERT INTO item_serial
                                (item, location, serial_number, on_hand_quantity,
                                 sold_quantity, reserved_quantity, inventory_amount,
                                 average_cost, changed_date, changed_user_id,
                                 container_id, package, country_of_origin )
                          VALUES (@s_newitem, @s_newlocation, @s_newserial,
                                  @c_newquantity * -1, 0, 0, @c_newamount * -1,
                                  @c_averagecost,
                                  GetDate(), @s_newchangeduserid,
                                  @s_newcontainerid, @s_newpackage,
                                  @s_newcountryoforigin )
                  END
              END
         END /* while loop */

      /*  don't need this cursor any longer  */
      CLOSE upditemtranscursor

      DEALLOCATE upditemtranscursor

    END
  END
GO
ALTER TABLE [dbo].[item_transactions] ADD CONSTRAINT [pk_item_transactions] PRIMARY KEY CLUSTERED  ([document_type], [document_id1], [document_id2], [document_id3], [document_line]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [item_transactions_batch] ON [dbo].[item_transactions] ([batch], [document_type], [document_id1]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [item_transactions_docid2] ON [dbo].[item_transactions] ([document_id2], [document_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [item_transactions_gldate] ON [dbo].[item_transactions] ([item], [location], [gl_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [item_transactions_item] ON [dbo].[item_transactions] ([item], [location], [serial_number]) ON [PRIMARY]
GO
