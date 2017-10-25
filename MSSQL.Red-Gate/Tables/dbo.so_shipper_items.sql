CREATE TABLE [dbo].[so_shipper_items]
(
[shipper] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sort_line] [decimal] (18, 6) NULL,
[shipper_line] [smallint] NOT NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serial_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity_shipped] [decimal] (18, 6) NULL,
[selling_to_inventory_conv] [decimal] (18, 6) NULL,
[cost] [decimal] (18, 6) NULL,
[extended_amount] [decimal] (18, 6) NULL,
[exchanged_amount] [decimal] (18, 6) NULL,
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[so_line] [smallint] NULL,
[invoice] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_line] [smallint] NULL,
[container_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vessel_container] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country_of_origin] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[account_manager_percent] [decimal] (18, 6) NULL,
[sales_agent_percent] [decimal] (18, 6) NULL,
[package] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[debit_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[credit_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_transaction_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_gross_weight] [decimal] (18, 6) NULL,
[package_net_weight] [decimal] (18, 6) NULL,
[package_weight_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_gross_weight_kgs] [decimal] (18, 6) NULL,
[package_net_weight_kgs] [decimal] (18, 6) NULL,
[package_width] [decimal] (18, 6) NULL,
[package_length] [decimal] (18, 6) NULL,
[package_height] [decimal] (18, 6) NULL,
[package_dimensions_uom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[number_of_packages] [decimal] (18, 6) NULL,
[rma_shipper] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rma_shipper_line] [smallint] NULL,
[shipper_rma_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_ShipperItems]
ON [dbo].[so_shipper_items] FOR DELETE
AS
/* 02/24/2004 Get the shipper_rma_flag from the so_shipper_items instead of from
              the so_shippers. */

/* 01/08/2004 If the shipper is really an RMA, check the update_sales_order flag
              to determine whether or not to update the so_item quantity_shipped. */

  BEGIN

    DECLARE @c_quantityshipped dec(18,6),
            @c_conv dec(18,6),
            @s_salesorder varchar(25),
            @s_changeduserid varchar(25),
            @s_item varchar(50),
            @s_shipper varchar(25),
            @s_updatesalesorder char(1),
            @s_shipperrmaflag char(1),
            @i_soline int,
            @i_rowcount int

  /*  Make sure that we have a row in the deleted table for processing */
  SELECT @i_rowcount = Count(*) FROM deleted

  IF @i_rowcount > 0
    BEGIN
      DECLARE delshipitemcursor CURSOR FOR
        SELECT deleted.sales_order,
               deleted.so_line,
               IsNull(deleted.quantity_shipped,0),
               IsNull(deleted.selling_to_inventory_conv,1),
               deleted.changed_user_id,
               deleted.shipper,
               deleted.shipper_rma_flag
          FROM deleted

      OPEN delshipitemcursor

      WHILE 1 = 1
        BEGIN
          FETCH delshipitemcursor
           INTO @s_salesorder,
                @i_soline,
                @c_quantityshipped,
                @c_conv,
                @s_changeduserid,
                @s_shipper,
                @s_shipperrmaflag

          /* any status from the fetch other than 0 will terminate the
             loop. */
          IF @@fetch_status <> 0 BREAK


            -- get the update sales order flag
            SELECT @s_updatesalesorder = IsNull(update_sales_order, '')
              FROM so_shippers
             WHERE shipper = @s_shipper AND
                   shipper_rma_flag = @s_shipperrmaflag

            IF @@rowcount > 0
              BEGIN
                IF (@s_shipperrmaflag = 'S') OR (@s_shipperrmaflag = 'R' AND
                   @s_updatesalesorder = 'Y')
                  BEGIN

                    IF @c_conv = 0 SELECT @c_conv = 1

                      -- determine if a row exists in the sales order item table
                      SELECT @s_item = item
                        FROM so_items
                       WHERE sales_order = @s_salesorder AND
                             so_line = @i_soline

                      IF @@rowcount > 0
                        BEGIN
                          -- row found, so update it
                          UPDATE so_items
                             SET quantity_shipped = quantity_shipped -
                                      (@c_quantityshipped / @c_conv),
                                 changed_date = GetDate(),
                                 changed_user_id = @s_changeduserid
                           WHERE sales_order = @s_salesorder AND
                                 so_line = @i_soline
                        END
                  END
            END
        END
      /*  don't need this cursor any longer  */
      CLOSE delshipitemcursor
      DEALLOCATE delshipitemcursor
    END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_ShipperItems]
ON [dbo].[so_shipper_items] FOR INSERT
AS

/* 02/24/2004 Get the shipper_rma_flag from the so_shipper_items instead of from
              the so_shippers. */

/* 01/08/2004 If the shipper is really an RMA, check the update_sales_order flag
              to determine whether or not to update the so_item quantity_shipped. */

  BEGIN
    DECLARE @c_quantityshipped dec(18,6),
            @c_conv dec(18,6),
            @s_salesorder varchar(25),
            @s_changeduserid varchar(25),
            @s_item varchar(50),
            @s_shipper varchar(25),
            @s_updatesalesorder char(1),
            @s_shipperrmaflag char(1),
            @i_soline int,
            @i_rowcount int

  /*  Make sure that we have a row in the inserted table for processing */
  SELECT @i_rowcount = Count(*) FROM inserted

  IF @i_rowcount > 0
    BEGIN
      DECLARE insshipitemcursor CURSOR FOR
        SELECT inserted.sales_order,
               inserted.so_line,
               IsNull(inserted.quantity_shipped,0),
               IsNull(inserted.selling_to_inventory_conv,1),
               inserted.changed_user_id,
               inserted.shipper,
               inserted.shipper_rma_flag
          FROM inserted

        OPEN insshipitemcursor

        WHILE 1 = 1
          BEGIN
            FETCH insshipitemcursor
             INTO @s_salesorder,
                  @i_soline,
                  @c_quantityshipped,
                  @c_conv,
                  @s_changeduserid,
                  @s_shipper,
                  @s_shipperrmaflag

            /* any status from the fetch other than 0 will terminate the
               loop. */
            IF @@fetch_status <> 0 BREAK

            -- get the update sales order flag
            SELECT @s_updatesalesorder = IsNull( update_sales_order, '' )
              FROM so_shippers
             WHERE shipper = @s_shipper AND
                   shipper_rma_flag = @s_shipperrmaflag

            IF @@rowcount > 0
              BEGIN
                IF (@s_shipperrmaflag = 'S') OR (@s_shipperrmaflag = 'R' AND
                   @s_updatesalesorder = 'Y')
                  BEGIN

                    IF @c_conv = 0 SELECT @c_conv = 1

                      -- determine if a row exists in the sales order items table
                      SELECT @s_item = item
                        FROM so_items
                       WHERE sales_order = @s_salesorder AND
                             so_line = @i_soline

                      IF @@rowcount > 0
                        BEGIN
                          -- row found, so update it
                          UPDATE so_items
                             SET quantity_shipped = quantity_shipped +
                                                   (@c_quantityshipped / @c_conv),
                                 changed_date = GetDate(),
                                 changed_user_id = @s_changeduserid
                           WHERE sales_order = @s_salesorder AND
                                 so_line = @i_soline
                        END
                  END
              END
           END

        CLOSE insshipitemcursor
        DEALLOCATE insshipitemcursor
    END
  END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_ShipperItems]
ON [dbo].[so_shipper_items] FOR UPDATE
AS

/* 02/24/2004 Get the shipper_rma_flag from the so_shipper_items instead of from
              the so_shippers. */

/* 01/08/2004 If the shipper is really an RMA, check the update_sales_order flag
              to determine whether or not to update the so_item quantity_shipped. */

IF UPDATE(quantity_shipped)
  BEGIN

    DECLARE @c_quantityshipped dec(18,6),
            @c_oldquantityshipped dec(18,6),
            @c_conv dec(18,6),
            @c_oldconv dec(18,6),
            @s_salesorder varchar(25),
            @s_changeduserid varchar(25),
            @s_item varchar(50),
            @s_shipper varchar(25),
            @s_oldupdatesalesorder char(1),
            @s_updatesalesorder char(1),
            @s_shipperrmaflag char(1),
            @i_soline int,
            @i_rowcount int

     /*  Make sure that we have a row in the inserted table for processing */
    SELECT @i_rowcount = Count(*) FROM inserted

    IF @i_rowcount > 0
      BEGIN
        DECLARE updshipitemcursor CURSOR FOR
          SELECT inserted.sales_order,
                 inserted.so_line,
                 IsNull(inserted.quantity_shipped,0),
                 IsNull(inserted.selling_to_inventory_conv,1),
                 IsNull(deleted.quantity_shipped,0),
                 IsNull(deleted.selling_to_inventory_conv,1),
                 inserted.changed_user_id,
                 inserted.shipper,
                 inserted.shipper_rma_flag
            FROM inserted, deleted
           WHERE inserted.sales_order = deleted.sales_order AND
                 inserted.so_line = deleted.so_line

        OPEN updshipitemcursor

        WHILE 1 = 1
          BEGIN
            FETCH updshipitemcursor
             INTO @s_salesorder,
                  @i_soline,
                  @c_quantityshipped,
                  @c_conv,
                  @c_oldquantityshipped,
                  @c_oldconv,
                  @s_changeduserid,
                  @s_shipper,
                  @s_shipperrmaflag

            /* any status from the fetch other than 0 will terminate the
               loop. */
            IF @@fetch_status <> 0 BREAK

            -- determine if this is a shipper or RMA
            SELECT @s_updatesalesorder = IsNull(update_sales_order,'')
              FROM so_shippers
             WHERE shipper = @s_shipper AND
                   shipper_rma_flag = @s_shipperrmaflag

            IF @@rowcount > 0
              BEGIN
                IF (@s_shipperrmaflag = 'S') OR (@s_shipperrmaflag = 'R' AND
                   @s_updatesalesorder = 'Y')
                  BEGIN

                    IF @c_conv = 0 SELECT @c_conv = 1
                    IF @c_oldconv = 0 SELECT @c_oldconv = 1

                    -- first need to find out if a row exists for the shipper line item
                    -- in the so item table
                    SELECT @s_item = item
                      FROM so_items
                     WHERE sales_order = @s_salesorder AND
                           so_line = @i_soline

                    IF @@rowcount > 0
                      BEGIN
                        -- there should always be a row
                        -- update it
                        UPDATE so_items
                           SET quantity_shipped = quantity_shipped -
                                  (@c_oldquantityshipped / @c_oldconv) +
                                  (@c_quantityshipped / @c_conv),
                               changed_date = GetDate(),
                               changed_user_id = @s_changeduserid
                         WHERE sales_order = @s_salesorder AND
                               so_line = @i_soline
                      END
                  END
              END
          END
        /*  don't need this cursor any longer  */
        CLOSE updshipitemcursor
        DEALLOCATE updshipitemcursor
      END
  END
GO
ALTER TABLE [dbo].[so_shipper_items] ADD CONSTRAINT [pk_so_shipper_items] PRIMARY KEY CLUSTERED  ([shipper], [shipper_rma_flag], [shipper_line]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [shipper_items_sales_order] ON [dbo].[so_shipper_items] ([sales_order], [so_line]) ON [PRIMARY]
GO
