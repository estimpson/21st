SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ARTaxesCollectedReport]
                                    @as_taxbegin VARCHAR(25),
                                    @as_taxend VARCHAR(25),
                                    @ad_collecteddatebegin datetime,
                                    @ad_collecteddateend datetime,
                                    @as_billunitbegin VARCHAR(25),
                                    @as_billunitend VARCHAR(25)
AS

BEGIN

-- 01-Feb-2008 Added query to return point of sale and direct sale
--             documents.

  CREATE TABLE #ar_taxescollected_rpt
          (bill_customer VARCHAR(25) NULL,
          bill_customer_name VARCHAR(100) NULL,
          item VARCHAR(50) NULL,
          document_type VARCHAR(25) NULL,
          document VARCHAR(25) NULL,
          document_date DATETIME NULL,
          document_line SMALLINT,
          last_applied_date DATETIME NULL,
          quantity DECIMAL(18,6),
          extended_amount DECIMAL(18,6) NULL,
          cash_applied_amount DECIMAL(18,6) NULL,
          credit_applied_amount DECIMAL(18,6) NULL)

  DECLARE @s_document VARCHAR(25)

-- Get the point of sale and direct sale invoices and credit memos
-- that were paid during the selected dates.
   INSERT INTO #ar_taxescollected_rpt
   SELECT ar_headers.bill_customer,
          ar_headers.bill_name,
          item,
          ar_headers.document_type,
          ar_headers.document,
          ar_headers.document_date,
          ar_items.document_line,
          ar_headers.gl_date,
          ar_items.quantity,
          ar_items.extended_amount,
          ar_headers.applied_amount,
          0
     FROM ar_headers, ar_items
     WHERE ar_headers.document_source in ('DS','PS')
       AND ar_headers.pos_paid = 'Y'
       AND ar_headers.gl_date BETWEEN @ad_collecteddatebegin AND @ad_collecteddateend
       AND ar_headers.bill_unit BETWEEN @as_billunitbegin AND @as_billunitend
       AND ar_headers.document = ar_items.document
       AND ar_headers.document_type = ar_items.document_type
       AND ar_items.line_type = 'TX'
       AND ar_items.item BETWEEN @as_taxbegin AND @as_taxend

-- The quantity (tax basis) on credit memos is stored as a positive
-- number.  We want it to show as a negative number on reports.
-- This is only applicable for POS and DS documents.  The following
-- queries don't pick up credit memos.
   UPDATE #ar_taxescollected_rpt
      SET quantity = quantity * -1.0
    WHERE document_type = 'C'

/* Get all fully paid AR invoices for the date range */

  DECLARE taxescollectedcursor CURSOR FOR
    SELECT ar_headers.document
     FROM ar_headers, ar_applications, ar_items
    WHERE ar_headers.document_type = ar_applications.document_type AND
          ar_headers.document = ar_applications.document AND
          ar_headers.document_type = 'I' AND
          (ar_headers.amount - ar_headers.applied_amount = 0) AND
          ar_headers.document_type = ar_items.document_type and
		  ar_headers.document = ar_items.document and
		  ar_items.line_type = 'TX' and
		  ar_items.item >= @as_taxbegin and
		  ar_items.item <= @as_taxend and
		  ar_headers.bill_unit >= @as_billunitbegin and
		  ar_headers.bill_unit <= @as_billunitend
    GROUP BY ar_headers.document,
             ar_headers.amount,
             ar_headers.document_date
    HAVING MAX(ar_applications.applied_date) >= @ad_collecteddatebegin and
				MAX(ar_applications.applied_date) <= @ad_collecteddateend
    ORDER BY ar_headers.document

  OPEN taxescollectedcursor

  WHILE 1 = 1
      BEGIN
      FETCH taxescollectedcursor INTO @s_document

      IF @@fetch_status <> 0 BREAK

      INSERT INTO #ar_taxescollected_rpt
      SELECT ar_headers.bill_customer,
             ar_headers.bill_name,
             item,
             ar_headers.document_type,
             ar_headers.document,
             ar_headers.document_date,
             ar_items.document_line,
             MAX(ar_applications.applied_date),
             MAX(quantity),
             MAX(extended_amount),
             (SELECT SUM(ar_applications.applied_amount)
              FROM ar_applications
              WHERE ar_applications.document_type = 'I' AND
                    ar_applications.document = @s_document AND
                    ar_applications.application_type = 'CHECK'),
             (SELECT SUM(ar_applications.applied_amount)
               FROM ar_applications
              WHERE ar_applications.document_type = 'I' AND
                    ar_applications.document = @s_document AND
                    ar_applications.application_type <> 'CHECK')
        FROM ar_applications, ar_items, ar_headers
        WHERE ar_headers.document = @s_document AND
            ar_headers.document_type = 'I' AND
            ar_headers.document = ar_applications.document AND
            ar_headers.document_type = ar_applications.document_type AND
            ar_headers.document = ar_items.document AND
            ar_headers.document_type = ar_items.document_type AND
            ar_items.line_type = 'TX' and
            ar_items.item >= @as_taxbegin and
            ar_items.item <= @as_taxend
        GROUP BY ar_headers.bill_customer,
            ar_headers.bill_name,
            ar_items.item,
            ar_headers.document_type,
            ar_headers.document,
            ar_headers.document_date,
            ar_items.document_line,
            extended_amount
   END

CLOSE taxescollectedcursor
DEALLOCATE taxescollectedcursor

SELECT  bill_customer,
        bill_customer_name,
        item,
        document_type,
        document,
        document_date,
        document_line,
        last_applied_date,
        quantity,
        extended_amount,
        IsNull(cash_applied_amount,0),
        IsNull(credit_applied_amount,0)
    FROM #ar_taxescollected_rpt
 ORDER BY item,
          bill_customer,
          document_date


END
GO
