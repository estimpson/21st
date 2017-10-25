CREATE TABLE [dbo].[iv_items]
(
[document_id1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[document_line] [int] NOT NULL,
[item] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serial_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [decimal] (18, 6) NULL,
[document_amount] [decimal] (18, 6) NULL,
[unit_of_measure] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sort_line] [int] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[unit_cost] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_IvItems]
ON [dbo].[iv_items] FOR INSERT
AS
  BEGIN
    DECLARE @s_item varchar(50),
            @s_location varchar(25),
            @s_serial varchar(50),
            @d_gldate datetime,
            @s_glentry varchar(50),
            @s_fiscalyear varchar(25),
            @i_period smallint,
            @s_transtype varchar(25),
            @c_quantity dec(18,6),
            @c_amount dec(18,6),
            @s_changeduserid varchar(25),
            @s_unit varchar(25),
            @s_batch varchar(50),
            @s_ledger varchar(40),
            @s_drledgeraccount varchar(40),
            @s_crledgeraccount varchar(40),
            @s_documenttype varchar(25),
            @s_documentid1 varchar(25),
            @s_documentid2 varchar(25),
            @s_documentid3 varchar(25),
            @i_documentline smallint,
            @c_unitcost decimal(18,6),
            @i_rowcount int

  /*  Make sure that we have a row in the inserted table for processing */
  SELECT @i_rowcount = Count(*) FROM inserted

  IF @i_rowcount > 0
    BEGIN

      DECLARE insivitemcursor CURSOR FOR
        SELECT inserted.item,
               inserted.location,
               inserted.serial_number,
               iv_headers.gl_date,
               iv_headers.gl_entry,
               iv_headers.fiscal_year,
               iv_headers.period,
               iv_headers.transaction_type,
               IsNull(inserted.quantity,0),
               IsNull(inserted.document_amount,0),
               iv_headers.unit,
               iv_headers.batch,
               iv_headers.ledger,
               (select min(ledger_account)
                  from gl_cost_transactions glc1
                 where glc1.document_type = inserted.document_type
                   and glc1.document_id1 = inserted.document_id1
                   and glc1.document_line = 0),
               (select min(ledger_account)
                  from gl_cost_transactions glc1
                 where glc1.document_type = inserted.document_type
                   and glc1.document_id1 = inserted.document_id1
                   and glc1.document_line = 1),
               inserted.document_type,
               inserted.document_id1,
               inserted.document_line,
               IsNull(inserted.unit_cost,0),
               inserted.changed_user_id
          FROM inserted, iv_headers
         WHERE inserted.document_type = iv_headers.document_type
           AND inserted.document_id1 = iv_headers.document_id1

        OPEN insivitemcursor

        WHILE 1 = 1
          BEGIN
            FETCH insivitemcursor
             INTO @s_item,
                  @s_location,
                  @s_serial,
                  @d_gldate,
                  @s_glentry,
                  @s_fiscalyear,
                  @i_period,
                  @s_transtype,
                  @c_quantity,
                  @c_amount,
                  @s_unit,
                  @s_batch,
                  @s_ledger,
                  @s_drledgeraccount,
                  @s_crledgeraccount,
                  @s_documenttype,
                  @s_documentid1,
                  @i_documentline,
                  @c_unitcost,
                  @s_changeduserid

            /* any status from the fetch other than 0 will terminate the
               loop. */

            IF @@fetch_status <> 0 BREAK
			/* need to put an empty string on document_id2 and document_id3
				as they are part of the primary key for item_transactions */
			select @s_documentid2 = ''
			select @s_documentid3 = ''
			select @s_serial = ''
            INSERT INTO item_transactions
              (item, location, serial_number, gl_date, gl_entry,
               fiscal_year, period, transaction_type,
               quantity, amount,
               debit_ledger_account, credit_ledger_account,
               changed_date, changed_user_id,
               unit, batch, ledger, document_type,
               document_id1, document_id2, document_id3,
               document_line, unit_cost)
             VALUES
               (@s_item, @s_location, @s_serial, @d_gldate, @s_glentry,
                @s_fiscalyear, @i_period, @s_transtype,
                @c_quantity, @c_amount,
                @s_drledgeraccount, @s_crledgeraccount,
                GetDate(), @s_changeduserid,
                @s_unit, @s_batch, @s_ledger, 'INVENTORY',
                @s_documentid1, @s_documentid2, @s_documentid3,
                @i_documentline, @c_unitcost)
          END

          CLOSE insivitemcursor

          DEALLOCATE insivitemcursor

    END
  END
GO
ALTER TABLE [dbo].[iv_items] ADD CONSTRAINT [pk_iv_items] PRIMARY KEY CLUSTERED  ([document_id1], [document_type], [document_line]) ON [PRIMARY]
GO
