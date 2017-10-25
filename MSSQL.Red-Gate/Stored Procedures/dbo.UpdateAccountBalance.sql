SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE
[dbo].[UpdateAccountBalance] @as_fiscalyear varchar(5),@as_ledger varchar(40),@as_ledgeraccount varchar(50),@as_balancename varchar(40),@as_userid varchar(25),@ai_period smallint,@ac_amount decimal(18,6) AS
BEGIN
  DECLARE @c_periodamount decimal(18,6)

--SET self_recursion on

  SELECT @c_periodamount = period_amount
    FROM ledger_balances
   WHERE fiscal_year=@as_fiscalyear
    AND ledger=@as_ledger
    AND ledger_account=@as_ledgeraccount
    AND balance_name=@as_balancename
    AND period=@ai_period

  IF @@ROWCOUNT = 0
    BEGIN
       /*  Assume that the row is not found! */
       INSERT INTO ledger_balances
          (fiscal_year,ledger,ledger_account,balance_name,period,
           period_amount,changed_date,changed_user_id)
        VALUES
          (@as_fiscalyear,@as_ledger,@as_ledgeraccount,@as_balancename,
           @ai_period,@ac_amount,GETDATE(),@as_userid)
    END
  ELSE
    BEGIN
      /*  Update the existing row  */
      UPDATE ledger_balances
         SET period_amount=period_amount+@ac_amount,
             changed_date=GETDATE(),
             changed_user_id=@as_userid
       WHERE fiscal_year=@as_fiscalyear
        AND ledger=@as_ledger
        AND ledger_account=@as_ledgeraccount
        AND balance_name=@as_balancename
        AND period=@ai_period
    END
END
GO
