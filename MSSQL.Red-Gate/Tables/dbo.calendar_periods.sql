CREATE TABLE [dbo].[calendar_periods]
(
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[calendar] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[period] [smallint] NOT NULL,
[period_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period_start_date] [datetime] NULL,
[period_end_date] [datetime] NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active_inactive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period_class] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_CalendarPeriods]
ON [dbo].[calendar_periods] FOR DELETE
AS


-- 14-Oct-07 This trigger is used to create a Calendar_headers row whenever all
-- of the periods in a fiscal_year, calendar are deleted
	BEGIN
    DECLARE @i_rowcount int,
			@s_fiscalyear varchar(25),
			@s_calendar varchar(25),
			@s_changeduserid varchar(25),
			@s_calendarheaderfiscalyear varchar(25),
			@s_calendarheadercalendar varchar (25)

	/*  Make sure that we have a row in the deleted table for processing */
	SELECT @i_rowcount = Count(*) FROM deleted

	IF @i_rowcount > 0
		BEGIN

		DECLARE delcalendarperiodcursor CURSOR FOR
        SELECT deleted.fiscal_year,
               deleted.calendar,
               deleted.changed_user_id
          FROM deleted

        OPEN delcalendarperiodcursor

        WHILE 1 = 1
			BEGIN
            FETCH delcalendarperiodcursor
             INTO @s_fiscalyear,
                  @s_calendar,
                  @s_changeduserid

            /* any status from the fetch other than 0 will terminate the
               loop. */
            IF @@fetch_status <> 0 BREAK
            -- determine if a row exists in the calendar_headers table.
            SELECT @i_rowcount = count(*)
				FROM calendar_headers
				WHERE fiscal_year= @s_fiscalyear AND
                   calendar = @s_calendar

			IF @i_rowcount > 0
				BEGIN
				SELECT @i_rowcount =  count(*)
					FROM calendar_periods
					WHERE fiscal_year = @s_fiscalyear and calendar = @s_calendar
					IF @i_rowcount = 0
						BEGIN
						-- header row found and no calendar period rows exist, so delete the headers row
							DELETE calendar_headers
								WHERE fiscal_year = @s_fiscalyear AND
													calendar = @s_calendar
						END
				END
			END
		END


          CLOSE delcalendarperiodcursor
          DEALLOCATE delcalendarperiodcursor

  END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_CalendarPeriods]
ON [dbo].[calendar_periods] FOR INSERT
AS


-- 14-Oct-07 Need to create a row in calendar_headers if a new fiscal_year, calendar is inserted

BEGIN
DECLARE @i_rowcount int,
		@s_fiscalyear varchar(25),
		@s_calendar varchar(25),
		@s_changeduserid varchar(25),
		@s_calendarheadersfiscalyear varchar(25),
		@s_calendarheaderscalendar varchar (25)

	/*  Make sure that we have a row in the inserted table for processing */
	SELECT @i_rowcount = Count(*) FROM inserted

	IF @i_rowcount > 0
	BEGIN
		DECLARE inscalendarperiodscursor CURSOR FOR
		SELECT inserted.fiscal_year,
			   inserted.calendar,
			   inserted.changed_user_id
		FROM inserted

		OPEN inscalendarperiodscursor

		WHILE 1 = 1
		BEGIN
			FETCH inscalendarperiodscursor
			 INTO @s_fiscalyear,
				  @s_calendar,
				  @s_changeduserid

			/* any status from the fetch other than 0 will terminate the
			   loop. */
			IF @@fetch_status <> 0 BREAK

			-- determine if a row exists in the calendar_headers table
			SELECT	@s_calendarheadersfiscalyear = fiscal_year,
					@s_calendarheaderscalendar = calendar
			  FROM calendar_headers
			 WHERE fiscal_year = @s_fiscalyear AND
				   calendar = @s_calendar
	
			IF @@rowcount = 0
			BEGIN
				-- row not found, so insertit
				INSERT INTO calendar_headers
					   (fiscal_year, calendar, changed_date, changed_user_id, active_inactive)
				VALUES (@s_fiscalyear, @s_calendar, Getdate(),@s_changeduserid, 'A')
			END
		END
	CLOSE inscalendarperiodscursor
    DEALLOCATE inscalendarperiodscursor

	END
END
GO
ALTER TABLE [dbo].[calendar_periods] ADD CONSTRAINT [pk_calendar_periods] PRIMARY KEY CLUSTERED  ([fiscal_year], [calendar], [period]) ON [PRIMARY]
GO
