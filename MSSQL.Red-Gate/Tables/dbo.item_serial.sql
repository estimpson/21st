CREATE TABLE [dbo].[item_serial]
(
[item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[serial_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[on_hand_quantity] [decimal] (18, 6) NULL,
[sold_quantity] [decimal] (18, 6) NULL,
[reserved_quantity] [decimal] (18, 6) NULL,
[inventory_amount] [decimal] (18, 6) NULL,
[average_cost] [decimal] (18, 6) NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country_of_origin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[container_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[physical_inventory_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity_at_selection] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_ItemSerial]
ON [dbo].[item_serial] FOR INSERT
AS

-- 02-Nov-05 1. Modified to get the preference value for IVStandardCosting.
--              When standard costing is in effect, update the average cost
--              with the item location mimimum_average_cost which is also
--              as the standard cost.
--           2. When the on-hand quantity goes to zero, set the average cost
--              to zero.

-- 12-Apr-02 No longer set the average cost to zero when the on-hand
--           quantity goes to zero.

  BEGIN
    DECLARE @s_item varchar(50),
            @s_location varchar(25),
            @s_changeduserid varchar(25),
            @c_quantity dec(18,6),
            @c_amount dec(18,6),
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

      DECLARE insitemserialcursor CURSOR FOR
        SELECT inserted.item,
               inserted.location,
               IsNull(inserted.inventory_amount,0),
               IsNull(inserted.on_hand_quantity,0),
               inserted.changed_user_id
          FROM inserted

        OPEN insitemserialcursor

        WHILE 1 = 1
          BEGIN
            FETCH insitemserialcursor
             INTO @s_item,
                  @s_location,
                  @c_amount,
                  @c_quantity,
                  @s_changeduserid

            /* any status from the fetch other than 0 will terminate the
               loop. */
            IF @@fetch_status <> 0 BREAK

            -- add amounts
            UPDATE item_locations
               SET on_hand_quantity = on_hand_quantity + @c_quantity,
                   inventory_amount = inventory_amount + @c_amount,
                   changed_date = GetDate(),
                   changed_user_id = @s_changeduserid
             WHERE item = @s_item AND
                   location = @s_location

            IF @s_stdcosting = 'N'
              BEGIN
                -- update the average cost being careful not to divide
                -- by zero.
                UPDATE item_locations
                   SET average_cost =
                         Round(inventory_amount / on_hand_quantity, 5)
                 WHERE item = @s_item AND
                       location = @s_location AND
                       on_hand_quantity <> 0

                UPDATE item_locations
                   SET average_cost = 0
                 WHERE item = @s_item AND
                       location = @s_location AND
                       on_hand_quantity = 0
              END
            ELSE
              BEGIN
                -- Using standard costing.  Make sure the average cost
                -- is the "standard cost".
                UPDATE item_locations
                   SET average_cost =
                      (SELECT IsNull(minimum_ave_cost,0)
                         FROM item_locations
                        WHERE item_locations.item = @s_item
                          AND item_locations.location = @s_location )
                 WHERE item = @s_item AND
                       location = @s_location
              END
          END

          CLOSE insitemserialcursor
          DEALLOCATE insitemserialcursor

    END
  END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_ItemSerial]
ON [dbo].[item_serial] FOR UPDATE
AS

-- 02-Nov-05 1. Modified to get the preference value for IVStandardCosting.
--              When standard costing is in effect, update the average cost
--              with the item location mimimum_average_cost which is also
--              as the standard cost.
--           2. When the on-hand quantity goes to zero, set the average cost
--              to zero.

-- 12-Apr-02 No longer set the average cost to zero when the on-hand
--           quantity goes to zero.

-- 25-Feb-02 Join inserted to deleted on the primary key. Previously,
--           the join had no where clause.

IF update(inventory_amount) OR update(on_hand_quantity)

  BEGIN
    DECLARE @s_item varchar(50),
            @s_location varchar(25),
            @s_newchangeduserid varchar(25),
            @c_newquantity dec(18,6),
            @c_oldquantity dec(18,6),
            @c_newamount dec(18,6),
            @c_oldamount dec(18,6),
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

      DECLARE upditemserialcursor CURSOR FOR
        SELECT inserted.item,
               inserted.location,
               IsNull(deleted.inventory_amount,0),
               IsNull(inserted.inventory_amount,0),
               IsNull(deleted.on_hand_quantity,0),
               IsNull(inserted.on_hand_quantity,0),
               inserted.changed_user_id
          FROM inserted, deleted
         WHERE inserted.item = deleted.item AND
               inserted.location = deleted.location AND
               inserted.serial_number = deleted.serial_number

        OPEN upditemserialcursor

        WHILE 1 = 1
          BEGIN
            FETCH upditemserialcursor
             INTO @s_item,
                  @s_location,
                  @c_oldamount,
                  @c_newamount,
                  @c_oldquantity,
                  @c_newquantity,
                  @s_newchangeduserid

            /* any status from the fetch other than 0 will terminate the
               loop. */
            IF @@fetch_status <> 0 BREAK

            UPDATE item_locations
               SET on_hand_quantity = on_hand_quantity + @c_newquantity
                                      - @c_oldquantity,
                   inventory_amount = inventory_amount + @c_newamount
                                      - @c_oldamount,
                   changed_date = GetDate(),
                   changed_user_id = @s_newchangeduserid
             WHERE item = @s_item AND
                   location = @s_location

            IF @s_stdcosting = 'N'
              BEGIN
                -- update the old average cost being careful not to divide
                -- by zero.
                UPDATE item_locations
                   SET average_cost =
                         Round(inventory_amount / on_hand_quantity, 5)
                 WHERE item = @s_item AND
                       location = @s_location AND
                       on_hand_quantity <> 0

                UPDATE item_locations
                   SET average_cost = 0
                 WHERE item = @s_item AND
                       location = @s_location AND
                       on_hand_quantity = 0
              END
            ELSE
              BEGIN
                -- Using standard costing.  Make sure the average cost
                -- is the "standard cost".
                UPDATE item_locations
                   SET average_cost =
                      (SELECT IsNull(minimum_ave_cost,0)
                         FROM item_locations
                        WHERE item_locations.item = @s_item
                          AND item_locations.location = @s_location )
                 WHERE item = @s_item AND
                       location = @s_location
              END

         END /* while loop */

      /*  don't need this cursor any longer  */
      CLOSE upditemserialcursor
      DEALLOCATE upditemserialcursor

    END
  END
GO
ALTER TABLE [dbo].[item_serial] ADD CONSTRAINT [pk_item_serial] PRIMARY KEY CLUSTERED  ([item], [location], [serial_number]) ON [PRIMARY]
GO
