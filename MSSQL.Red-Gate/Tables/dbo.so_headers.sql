CREATE TABLE [dbo].[so_headers]
(
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ship_customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_contact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_address_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_address_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_address_3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_state] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_postal_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_contact_email_address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_contact_fax_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_contact_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_reference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quote_date] [datetime] NULL,
[quote_expiration_date] [datetime] NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_agent] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[account_manager] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_processor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[territory] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[price_group] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_percent] [decimal] (18, 6) NULL,
[payment_method] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deposit_required] [decimal] (18, 6) NULL,
[deposit_received] [decimal] (18, 6) NULL,
[ship_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_address_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_address_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_address_3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_state] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_postal_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_contact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_contact_email_address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_contact_fax_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_contact_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_markings] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[port_loading] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[port_discharge] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quote_notification] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_advice_notification] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_via] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allow_backorder] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acknowledgement_printed] [datetime] NULL,
[approved] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[confirmation_received_date] [datetime] NULL,
[confirmation_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acknowledgement_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quote_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[intercompany] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[finance_charge] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quote_revision_date] [datetime] NULL,
[quote_revision_number] [smallint] NULL,
[sales_term_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freight_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freight_carrier] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lcd_issuing_bank_address] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lcd_advising_bank_address] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lcd_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lcd_cover_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lcd_amount] [decimal] (18, 6) NULL,
[lcd_currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lcd_applicant] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lcd_beneficiary] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lcd_expiration_date] [datetime] NULL,
[status_note] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[so_amount] [decimal] (18, 6) NULL,
[exchanged_amount] [decimal] (18, 6) NULL,
[target_ship_date] [datetime] NULL,
[merchandise_amount] [decimal] (18, 6) NULL,
[other_expense_amount] [decimal] (18, 6) NULL,
[freight_amount] [decimal] (18, 6) NULL,
[tax_amount] [decimal] (18, 6) NULL,
[confirmation_requested_date] [datetime] NULL,
[ship_to_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consolidator] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consolidator_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consolidator_address_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consolidator_address_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consolidator_address_3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consolidator_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consolidator_state] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consolidator_postal_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consolidator_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consolidator_contact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consolidator_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consolidator_fax_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consolidator_email_address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_priority] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[so_ship_date] [datetime] NULL,
[so_eta_date] [datetime] NULL,
[so_cost] [decimal] (18, 6) NULL,
[so_merchandise_cost] [decimal] (18, 6) NULL,
[so_other_expense_cost] [decimal] (18, 6) NULL,
[so_freight_cost] [decimal] (18, 6) NULL,
[cancelled_date] [datetime] NULL,
[cancelled_reason] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_item_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_item_percent] [decimal] (18, 6) NULL,
[discount_item_basis] [decimal] (18, 6) NULL,
[discount_item_amount] [decimal] (18, 6) NULL,
[discount_item_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_item_cost_account] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_item_sales_analysis] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_item_tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_item_tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_item_agent_percent] [decimal] (18, 6) NULL,
[discount_item_manager_percent] [decimal] (18, 6) NULL,
[label_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[destination_label_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_SOHeaders]
ON [dbo].[so_headers] FOR UPDATE
AS
IF UPDATE(document_type) or UPDATE(approved)
  BEGIN

    DECLARE @s_salesorder varchar(25),
            @s_olddocumenttype char(1),
            @s_oldapproved char(1),
            @s_newdocumenttype char(1),
            @s_newapproved char(1),
            @i_soline int,
            @i_lastsoline int,
            @i_maxsoline int,
            @s_item varchar(25),
            @s_location varchar(25),
            @c_qtyordered dec(18,6),
            @c_qtycancelled dec(18,6),
            @c_qtyshipped dec(18,6),
            @c_sotostd dec(18,6),
            @s_inventoried char (1),
            @c_qty dec(18,6),
            @s_changeduserid varchar(25),
            @i_rowcount int

    /*  Make sure that we have a row in the inserted table for processing */
    SELECT @i_rowcount = Count(*) FROM inserted

    IF @i_rowcount > 0
      BEGIN
        /* Won't do special processing for one row versus many rows.
           We'll always use a cursor to avoid duplicating code. */
        DECLARE updsohdrcursor CURSOR FOR
          SELECT inserted.sales_order,
                 inserted.document_type, inserted.approved,
                 deleted.document_type, deleted.approved,
                 inserted.changed_user_id
            FROM inserted, deleted
           WHERE inserted.sales_order = deleted.sales_order
           ORDER BY inserted.sales_order

        OPEN updsohdrcursor

        WHILE 1 = 1
          BEGIN
            FETCH updsohdrcursor
             INTO @s_salesorder,
                 	@s_newdocumenttype, @s_newapproved,
                  @s_olddocumenttype, @s_oldapproved,
                  @s_changeduserid

            /* any status from the fetch other than 0 will terminate the
               loop. */
            IF @@fetch_status <> 0 BREAK

            /* No need for any more work if neither the old nor the new
               document_type value is 'O' (order). */
            IF @s_olddocumenttype <> 'O' AND @s_newdocumenttype <> 'O' CONTINUE

            /* No need for any more work if neither the old nor the new
               approved value is 'Y'. */
            IF @s_oldapproved <> 'Y' AND @s_newapproved <> 'Y' CONTINUE

            /* No need for any more work if neither the document_type nor
               the approved value changed. */
            IF @s_olddocumenttype = @s_newdocumenttype AND
               @s_oldapproved = @s_newapproved CONTINUE

            /* Set some initial values before processing the SO items. */
            SELECT @i_maxsoline = Max(so_line)
              FROM so_items
             WHERE sales_order = @s_salesorder

            IF @i_maxsoline IS NULL SELECT @i_maxsoline = 0

            SELECT @i_lastsoline = 0

            /* Now loop through the so items for this sales order */
            WHILE @i_lastsoline < @i_maxsoline
              BEGIN
                /* Use a trick used by Monitor to avoid defining a cursor
                   on so_items. */
                SELECT @i_soline = so_line,
                       @s_item = item,
                       @s_location = fulfillment_location,
                       @c_qtyordered = quantity_ordered,
                       @c_qtycancelled = IsNull(quantity_cancelled,0),
                       @c_qtyshipped = IsNull(quantity_shipped,0),
                       @c_sotostd = IsNull(selling_uom_to_standard,1),
                       @s_inventoried = inventoried
                  FROM so_items
                 WHERE sales_order = @s_salesorder AND
                       so_line = ( SELECT Min(so_line)
                                     FROM so_items
                                    WHERE sales_order = @s_salesorder
                                          AND so_line > @i_lastsoline )

                /* Save the SO line */
                SELECT @i_lastsoline = @i_soline

                IF @c_sotostd = 0 SELECT @c_sotostd = 1

                /* Have an SO item row. Does it need to update inventory? */
                IF @s_inventoried = 'Y' AND @s_item <> '' AND
                   @s_location <> '' AND
                  (@c_qtyordered - @c_qtycancelled - @c_qtyshipped ) <> 0
                  BEGIN
                    IF @s_olddocumenttype = 'O' AND @s_oldapproved = 'Y'
                      /* Remove the sold quantity from the location. */
                      BEGIN
                        SELECT @c_qty = Round((@c_qtyordered - @c_qtycancelled - @c_qtyshipped) *
                                  @c_sotostd * -1.0,4)
                        /* Qty will be > 0 if we shipped more than was ordered. */
                        IF @c_qty < 0
                          BEGIN
                            EXECUTE UpdateItemLocationQuantity
                                @s_item,
                                @s_location,
                                0,
                                @c_qty,
                                @s_changeduserid
                          END
                      END
                    IF @s_newdocumenttype = 'O' AND @s_newapproved = 'Y'
                      /* Add the sold quantity to the location. */
                      BEGIN
                        SELECT @c_qty = Round((@c_qtyordered - @c_qtycancelled - @c_qtyshipped) *
                                  @c_sotostd,4)
                        /* Qty will be < 0 if we shipped more than was ordered. */
                        IF @c_qty > 0
                          BEGIN
                            EXECUTE UpdateItemLocationQuantity
                                @s_item,
                                @s_location,
                                0,
                                @c_qty,
                                @s_changeduserid
                          END
                      END
                  END
              END /* inner loop */
          END /* outer loop */
        /*  don't need this cursor any longer  */
        CLOSE updsohdrcursor
        DEALLOCATE updsohdrcursor
      END /* have one or more rows in inserted */
  END
GO
ALTER TABLE [dbo].[so_headers] ADD CONSTRAINT [pk_so_headers] PRIMARY KEY CLUSTERED  ([sales_order]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [so_headers_customer] ON [dbo].[so_headers] ([bill_customer], [sales_order]) ON [PRIMARY]
GO
