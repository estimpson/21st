SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[BankRecDepositDetail] @as_bankalias VARCHAR(25),
                                 @ad_reconcileddate datetime,
                                 @as_securityid VARCHAR(25)
AS

-- 24-Apr-2014 Added "approved = 'Y' OR approved is null" to WHERE clause.

BEGIN
DECLARE @chkseparate CHAR(1),
        @application VARCHAR(25)

	/* First delete any rows in the bank rec deposit detail for this user */
	BEGIN TRANSACTION

	DELETE FROM bank_rec_deposit_detail
		 WHERE bank_alias = @as_bankalias
		   AND security_id = @as_securityid
                   AND statement_date = @ad_reconcileddate

	COMMIT

	/* Now get all the bank_register deposit detail rows  */
	BEGIN TRANSACTION
	INSERT INTO bank_rec_deposit_detail
          ( security_id,
           bank_alias,
           statement_date,
           document_class,
           document_number,
           check_void_nsf,
           document_id1,
           document_id2,
           document_id3,
           document_type,
           document_date,
           document_amount,
           reconciled,
           reconciled_date,
           reconciled_id,
           document_group_id,
           document_group_date,
           changed_date,
           changed_user_id,
           bank_account_debit_credit,
           document_reference,
           document_remarks,
           document_reference2,
	   document_source,
	   cmc_document_group_id,
	   cmc_document_group_date,
	   cmc_document_type,
	   reconciled_amount )
		SELECT
		   @as_securityid,
		   bank_alias,
                   @ad_reconcileddate,
		   document_class,
		   document_number,
		   check_void_nsf,
		   document_id1,
		   document_id2,
		   document_id3,
		   document_type,
		   document_date,
		   document_amount,
		   reconciled,
		   reconciled_date,
		   reconciled_id,
		   document_group_id,
		   document_group_date,
		   getdate(),
		   @as_securityid,
		   bank_account_debit_credit,
		   document_reference,
		   document_remarks,
		   document_reference2,
		   document_source,
		   document_group_id,
		   document_group_date,
		   document_type,
		   CASE
			WHEN reconciled = 'Y' THEN document_amount
			ELSE 0
			END
		FROM	bank_register
		WHERE	bank_alias = @as_bankalias and
				( approved = 'Y' OR approved = 'A' OR approved is null ) AND
				( reconciled = 'N' OR
					reconciled_date = @ad_reconcileddate ) AND
				(( document_class in ('AR','CR') AND
					check_void_nsf = 'C' ) OR
				 ( document_class = 'JE' AND
				   check_void_nsf = 'E' AND
				   document_type in ( 'EIN', 'ECA', 'ECX','CCA' )))

	COMMIT
	
	/* Return one row per document_group_id and document_group_date  */
	SELECT Sum( document_amount ),
		 Sum( reconciled_amount ),
		 document_group_date,
		 document_group_id,
		 Min( reconciled ),
		 Max( reconciled ),
		 Min( document_type )
	FROM bank_rec_deposit_detail
	WHERE security_id = @as_securityid AND statement_date = @ad_reconcileddate AND bank_alias = @as_bankalias
	GROUP BY	document_group_date,
			document_group_id
	ORDER BY	document_group_date,
			document_group_id

END
GO
