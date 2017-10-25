CREATE TABLE [dbo].[ledger_period_applications]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[period] [smallint] NOT NULL,
[application] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[closed] [bit] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_Update_LedPerApps]
   ON  [dbo].[ledger_period_applications]
   FOR INSERT, UPDATE
AS
BEGIN

	DECLARE @fiscal_year VARCHAR(5)
	DECLARE @ledger VARCHAR(40)
	DECLARE @period SMALLINT
	DECLARE @application VARCHAR(25)
	DECLARE @closed BIT
	DECLARE @je_committed char(1)

	DECLARE ledger_period_apps_iuc CURSOR FOR
		SELECT fiscal_year, ledger, period, application, ISNULL(closed,0)
                  FROM inserted

	OPEN ledger_period_apps_iuc

	FETCH ledger_period_apps_iuc INTO
		@fiscal_year,
		@ledger,
		@period,
		@application,
		@closed

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--  any fetch status other than 0 will stop the loop
		IF (@closed = 1)
		BEGIN
			SELECT @je_committed = 'Y'
		END
		ELSE
		BEGIN
			SELECT @je_committed = 'N'
		END
		
                UPDATE journal_entries
                   SET je_committed = @je_committed
                 WHERE fiscal_year = @fiscal_year AND
                       ledger = @ledger AND
                       period = @period AND
                       entry_type = @application
		
		/*  get the next inserted record, if any  */
		FETCH ledger_period_apps_iuc INTO
			@fiscal_year,
			@ledger,
			@period,
			@application,
			@closed	
	END

	/* Don't need the cursor any longer. */
	CLOSE ledger_period_apps_iuc
	DEALLOCATE ledger_period_apps_iuc

END
GO
ALTER TABLE [dbo].[ledger_period_applications] ADD CONSTRAINT [pk_ledger_period_applications] PRIMARY KEY CLUSTERED  ([fiscal_year], [ledger], [period], [application]) ON [PRIMARY]
GO
