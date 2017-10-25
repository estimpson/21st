SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE
[dbo].[UpdateGLBalances] @as_fiscalyear varchar(5),@as_ledger varchar(40),@as_ledgeraccount varchar(50),@as_balancename varchar(40),@as_userid varchar(25),@ai_period smallint,@ac_amount decimal(18,6) AS
BEGIN
  DECLARE @c_periodamount decimal(18,6),
          @s_posttoledger varchar(40),
          @s_posttoaccount varchar(50)

--SET self_recursion on

  SELECT @s_posttoledger=to_ledger, @s_posttoaccount=to_ledger_account
    FROM posting_relationships
   WHERE fiscal_year=@as_fiscalyear AND ledger=@as_ledger AND
         ledger_account=@as_ledgeraccount AND relationship='Reporting'

  IF @s_posttoaccount IS NOT NULL
    BEGIN
      /*  We need to roll this balance into another account  */

      /*  Select the period amount for the appropriate balance record  */
      SELECT @c_periodamount = period_amount
        FROM ledger_balances
       WHERE fiscal_year=@as_fiscalyear
         AND ledger=@s_posttoledger
         AND ledger_account=@s_posttoaccount
         AND balance_name=@as_balancename
         AND period=@ai_period

      IF @@rowcount = 0
        BEGIN
          /*  If a balance record doesn't exist then create one ... */
          INSERT INTO ledger_balances
             (fiscal_year,ledger,ledger_account,balance_name,period,
              period_amount,changed_date,changed_user_id)
            VALUES
             (@as_fiscalyear,@s_posttoledger,@s_posttoaccount,@as_balancename,
              @ai_period,@ac_amount,GETDATE(),@as_userid)
        END
      ELSE
        BEGIN
          /*  a balance record already exists so update it ...  */
          UPDATE ledger_balances
             SET period_amount=period_amount+@ac_amount,
                 changed_date=GETDATE(),
                 changed_user_id=@as_userid
           WHERE fiscal_year=@as_fiscalyear
            AND ledger=@s_posttoledger
            AND ledger_account=@s_posttoaccount
            AND balance_name=@as_balancename
            AND period=@ai_period
        END
    END
END
GO
