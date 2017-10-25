SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[BankRecWithdrawalDetail] @as_bankalias VARCHAR(25),
                                 @ad_reconcileddate datetime,
                                 @as_securityid VARCHAR(25)
AS

BEGIN
DECLARE @ddbatch CHAR(1),
	@campusvueintegrated CHAR(1)


	/* First delete any rows in the bank rec withdrawal detail for this user */
	BEGIN TRANSACTION

	DELETE FROM bank_rec_withdrawal_detail
		 WHERE bank_alias = @as_bankalias
		   AND security_id = @as_securityid
                   AND statement_date = @ad_reconcileddate

	COMMIT

	/* Need to read a Preference to find out if DD Checks are grouped by batch */
 	SELECT @ddbatch = IsNull(value,'')
	    FROM preferences_user
	    WHERE preference = 'BankReconciliationDDBatch'
	    AND security_id = @as_securityid
	IF @@rowcount = 0
	BEGIN
	    SELECT @ddbatch = IsNull(value,'')
		FROM preferences_standard
		WHERE preference = 'BankReconciliationDDBatch'
	    IF @@rowcount = 0 OR @ddbatch = '' SELECT @ddbatch = 'N'
	END

	/* Need to read a Preference to find out if this is CMC */
	SELECT @campusvueintegrated = IsNull(value,'')
	    FROM preferences_standard
	    WHERE preference = 'CampusVueIntegrated'
	IF @@rowcount = 0 OR @campusvueintegrated = '' SELECT @campusvueintegrated = 'N'

	/* Now get all the bank_register withdrawal detail rows  */
	BEGIN TRANSACTION
	INSERT INTO bank_rec_withdrawal_detail
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
	   dd_document_class,
	   dd_document_group_id,
	   dd_document_number,
	   dd_check_void_nsf,
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
		   CASE
			WHEN @ddbatch = 'Y' AND document_type = 'EDA' AND document_class = 'JE' AND document_group_id like 'PYDDD%' THEN 'DD'
			ELSE document_type
			END,
		   document_date,
		   CASE
			WHEN check_void_nsf = 'N' THEN document_amount * -1
			ELSE document_amount
			END,
		   reconciled,
		   reconciled_date,
		   reconciled_id,
		   document_group_id,
		   document_group_date,
		   getdate(),
		   @as_securityid,
		   bank_account_debit_credit,
		   document_reference,
		   convert( varchar(100), document_remarks ),
		   document_reference2,
		   document_source,
		   CASE
			WHEN @ddbatch = 'Y' AND document_type = 'EDA' AND document_class = 'JE' AND document_group_id like 'PYDDD%' THEN 'PY'
			ELSE document_class
			END,
		   CASE
			WHEN @ddbatch = 'Y' AND document_type = 'EDA' AND document_class = 'JE' AND document_group_id like 'PYDDD%' THEN substring(document_group_id, 6, 25)
			ELSE document_group_id
			END,
		   CASE
			WHEN @ddbatch = 'Y' AND ( document_type = 'DD' OR (document_type = 'EDA' AND document_class = 'JE' AND document_group_id like 'PYDDD%') ) THEN 0
			WHEN @campusvueintegrated = 'Y' and document_type = 'N' and document_class <> 'AR' THEN 0
			ELSE document_number
			END,
		   CASE
			WHEN @ddbatch = 'Y' AND document_type = 'EDA' AND document_class = 'JE' AND document_group_id like 'PYDDD%' AND check_void_nsf = 'E' THEN 'C'
			ELSE check_void_nsf
			END,
		   CASE
			WHEN reconciled = 'Y' THEN
			   CASE
				WHEN check_void_nsf = 'N' THEN document_amount * -1
				ELSE document_amount
				END
			ELSE 0
			END
		FROM	bank_register

		WHERE bank_alias = @as_bankalias AND
				( reconciled = 'N' OR reconciled_date = @ad_reconcileddate ) AND
				( document_type not in ('V', 'A', 'D', 'EIN', 'ECA', 'ECX', 'CCA' ) ) AND
				( document_class not in ('AR','CR') OR ( check_void_nsf = 'N' ) ) AND
				( check_void_nsf <> 'A' )

	COMMIT
	
	/* The following will return a summary row for DD withdrawals, and one row per withdrawal for other withdrawals  */
	SELECT Sum( document_amount ),
		Sum( reconciled_amount ),
		document_group_date,
	   	dd_document_group_id,
		Min( reconciled ),
		Max( reconciled ),
		document_type,
		CASE
		    WHEN @ddbatch = 'Y' AND document_type = 'DD' THEN ''
		    WHEN @campusvueintegrated = 'Y' and document_type = 'N' and dd_document_class <> 'AR' THEN ''
		    ELSE Min( document_id2 )
		    END,
		CASE
		    WHEN @ddbatch = 'Y' AND document_type = 'DD' THEN ''
		    WHEN @campusvueintegrated = 'Y' and document_type = 'N' and dd_document_class <> 'AR' THEN ''
		    ELSE Min( document_id3 )
		    END,
		CASE
		    WHEN @ddbatch = 'Y' AND document_type = 'DD' THEN 'Direct Deposit'
		    WHEN @campusvueintegrated = 'Y' and document_type = 'N' and dd_document_class <> 'AR' THEN 'NSF'
		    ELSE Min( document_reference )
		    END,
	   	dd_document_number,
		dd_document_class,
		dd_check_void_nsf,
		CASE
		    WHEN @ddbatch = 'Y' AND document_type = 'DD' THEN ''
		    WHEN @campusvueintegrated = 'Y' and document_type = 'N' and dd_document_class <> 'AR' THEN ''
		    ELSE Min( document_remarks )
		    END,
		@ddbatch,
		@campusvueintegrated

	FROM bank_rec_withdrawal_detail
	WHERE security_id = @as_securityid AND statement_date = @ad_reconcileddate AND bank_alias = @as_bankalias
	GROUP BY	document_group_date,
			dd_document_class,
			dd_document_group_id,
			dd_document_number,
			document_type,
			dd_check_void_nsf
	ORDER BY	document_group_date,
			dd_document_class,
			dd_document_group_id,
			dd_document_number

END
GO
