CREATE TABLE [dbo].[so_other_expenses]
(
[sales_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[estimated_cost] [decimal] (18, 6) NULL,
[invoiced_amount] [decimal] (18, 6) NULL,
[po_ledger_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_vendor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_date] [datetime] NULL,
[po_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_buyer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_required_date] [datetime] NULL,
[tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_cost_account] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[so_line] [smallint] NOT NULL,
[sort_line] [decimal] (8, 2) NULL,
[po_sales_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_sales_terms_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_freight_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_agent_percent] [decimal] (18, 6) NULL,
[account_manager_percent] [decimal] (18, 6) NULL,
[po_currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_ship_date] [datetime] NULL,
[po_eta_date] [datetime] NULL,
[po_terms] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_gl_date] [datetime] NULL,
[po_document_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchase_order] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_line] [smallint] NULL,
[po_tax_1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[po_tax_2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipped_amount] [decimal] (18, 6) NULL,
[cancelled_amount] [decimal] (18, 6) NULL,
[so_release] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blanket_line] [smallint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_SOOtherExpenses]
ON [dbo].[so_other_expenses] FOR DELETE
AS

BEGIN

  DECLARE @s_salesorder varchar(25),
          @s_documenttype char(1),
          @c_invoicedamt numeric(18,6),
          @i_blanketline smallint,
          @s_changeduserid varchar(25),
          @i_rowcount int

  /*  Make sure that we have a row in the deleted table for processing */
  SELECT @i_rowcount = Count(*) FROM deleted

  IF @i_rowcount > 0
    BEGIN
      DECLARE delsoothexpcursor CURSOR FOR
        SELECT deleted.sales_order,
               so_headers.document_type,
               IsNull(invoiced_amount,0),
               deleted.changed_user_id,
               blanket_line
        FROM so_headers,deleted
       WHERE so_headers.sales_order = deleted.sales_order

      OPEN delsoothexpcursor

      WHILE 1 = 1
        BEGIN
          FETCH delsoothexpcursor
           INTO @s_salesorder,
                @s_documenttype,
                @c_invoicedamt,
                @s_changeduserid,
                @i_blanketline

          /* any status from the fetch other than 0 will terminate the
             loop. */
          IF @@fetch_status <> 0 BREAK

          IF @s_documenttype = 'B' AND @i_blanketline <> 0
            BEGIN
              UPDATE so_blanket_other_expenses
                 SET cum_invoiced_amount =
                     cum_invoiced_amount - @c_invoicedamt,
                     changed_date = GetDate(),
                     changed_user_id = @s_changeduserid
               WHERE sales_order = @s_salesorder
                 AND blanket_line = @i_blanketline
            END
        END

      /*  don't need this cursor any longer  */
      CLOSE delsoothexpcursor
      DEALLOCATE delsoothexpcursor
    END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_SOOtherExpenses]
ON [dbo].[so_other_expenses] FOR INSERT
AS

BEGIN

  DECLARE @s_salesorder varchar(25),
          @s_documenttype char(1),
          @c_invoicedamt numeric(18,6),
          @i_blanketline smallint,
          @s_changeduserid varchar(25),
          @i_rowcount int

  /*  Make sure that we have a row in the deleted table for processing */
  SELECT @i_rowcount = Count(*) FROM inserted

  IF @i_rowcount > 0
    BEGIN
      DECLARE inssoothexpcursor CURSOR FOR
        SELECT inserted.sales_order,
               so_headers.document_type,
               IsNull(invoiced_amount,0),
               inserted.changed_user_id,
               blanket_line
        FROM so_headers,inserted
       WHERE so_headers.sales_order = inserted.sales_order

      OPEN inssoothexpcursor

      WHILE 1 = 1
        BEGIN
          FETCH inssoothexpcursor
           INTO @s_salesorder,
                @s_documenttype,
                @c_invoicedamt,
                @s_changeduserid,
                @i_blanketline

          /* any status from the fetch other than 0 will terminate the
             loop. */
          IF @@fetch_status <> 0 BREAK

          IF @s_documenttype = 'B' AND @i_blanketline <> 0
            BEGIN
              UPDATE so_blanket_other_expenses
                 SET cum_invoiced_amount =
                     cum_invoiced_amount + @c_invoicedamt,
                     changed_date = GetDate(),
                     changed_user_id = @s_changeduserid
               WHERE sales_order = @s_salesorder
                 AND blanket_line = @i_blanketline
            END
        END

      /*  don't need this cursor any longer  */
      CLOSE inssoothexpcursor
      DEALLOCATE inssoothexpcursor
    END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_SOOtherExpenses]
ON [dbo].[so_other_expenses] FOR UPDATE
AS

IF UPDATE(invoiced_amount)
  BEGIN

    DECLARE @s_salesorder varchar(25),
            @s_documenttype char(1),
            @c_invoicedamt numeric(18,6),
            @c_oldinvoicedamt numeric(18,6),
            @i_blanketline smallint,
            @s_changeduserid varchar(25),
            @i_rowcount int

    /*  Make sure that we have a row in the inserted table for processing */
    SELECT @i_rowcount = Count(*) FROM inserted

    IF @i_rowcount > 0
      BEGIN
        /* Only select approved sales orders. */
        DECLARE updsoothexpcursor CURSOR FOR
          SELECT inserted.sales_order,
                 so_headers.document_type,
                 IsNull(inserted.invoiced_amount,0),
                 IsNull(deleted.invoiced_amount,0),
                 inserted.blanket_line,
                 inserted.changed_user_id
            FROM so_headers, inserted, deleted
           WHERE inserted.sales_order = deleted.sales_order AND
                 inserted.so_line = deleted.so_line AND
                 so_headers.sales_order = inserted.sales_order
        ORDER BY inserted.sales_order, inserted.so_line

        OPEN updsoothexpcursor

        WHILE 1 = 1
          BEGIN
            FETCH updsoothexpcursor
             INTO @s_salesorder,
                  @s_documenttype,
                  @c_invoicedamt,
                  @c_oldinvoicedamt,
                  @i_blanketline,
                  @s_changeduserid

            /* any status from the fetch other than 0 will terminate the
               loop. */
            IF @@fetch_status <> 0 BREAK

            IF @s_documenttype = 'B' AND @i_blanketline <> 0
              BEGIN
                UPDATE so_blanket_other_expenses
                   SET cum_invoiced_amount =
                       cum_invoiced_amount + @c_invoicedamt
                             - @c_oldinvoicedamt,
                       changed_date = GetDate(),
                       changed_user_id = @s_changeduserid
                 WHERE sales_order = @s_salesorder
                   AND blanket_line = @i_blanketline
             END /* have a blanket item to update */

          END /* while loop */
          /*  don't need this cursor any longer  */
          CLOSE updsoothexpcursor
          DEALLOCATE updsoothexpcursor
      END /* have one or more rows in inserted */
  END
GO
ALTER TABLE [dbo].[so_other_expenses] ADD CONSTRAINT [pk_so_other_expenses] PRIMARY KEY CLUSTERED  ([sales_order], [so_line]) ON [PRIMARY]
GO
