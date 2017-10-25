CREATE TABLE [dbo].[ar_applications]
(
[application_number] [int] NOT NULL,
[application_line] [smallint] NOT NULL,
[application_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[document] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reversed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reversal] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_customer] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[applied_document_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[applied_document] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[applied_amount] [decimal] (18, 6) NULL,
[applied_date] [datetime] NULL,
[fiscal_year] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[period] [smallint] NULL,
[gl_entry] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offset_ledger_account_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ledger] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changed_date] [datetime] NULL,
[changed_user_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exchanged_amount] [decimal] (18, 6) NULL,
[offset_exchanged_amount] [decimal] (18, 6) NULL,
[gain_loss_amount] [decimal] (18, 6) NULL,
[offset_gain_loss_amount] [decimal] (18, 6) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Delete_ARApplications]
ON [dbo].[ar_applications] FOR DELETE
AS
BEGIN

  DECLARE @s_applicationtype VARCHAR(6),
          @s_documenttype char(1),
          @s_document VARCHAR(25),
          @s_changeduserid VARCHAR(25),
          @c_appliedamount decimal(18,6),
          @c_exchamount decimal(18,6),
          @c_offsetexchamount decimal(18,6),
          @c_crmexchamount decimal(18,6)

  DECLARE deletedcursor CURSOR FOR
      SELECT application_type, document_type, document, applied_amount,
             exchanged_amount, offset_exchanged_amount, changed_user_id
        FROM deleted

  OPEN deletedcursor

  /*  prime fetch  */
  FETCH deletedcursor INTO @s_applicationtype, @s_documenttype,
                            @s_document, @c_appliedamount,
                            @c_exchamount, @c_offsetexchamount,
                            @s_changeduserid

   WHILE @@fetch_status = 0

    BEGIN
       /*  any fetch status other than 0 will stop the loop  */

       /*  don't mess with document applied amount for overpayments */
      IF @s_applicationtype <> 'OVERPY'
        BEGIN
          IF @s_documenttype = 'I'
             /*  invoice application:
                    c_appliedamount is positive
                    c_offsetexchamount is negative (credit)  */
             UPDATE ar_headers
                SET applied_amount = IsNull(applied_amount,0) -
                                     IsNull(@c_appliedamount,0),
                    exchanged_applied_amount =
                                     IsNull(exchanged_applied_amount,0) +
                                     IsNull(@c_offsetexchamount,0),
                    changed_date = GetDate(),
                    changed_user_id = @s_changeduserid
               WHERE document_type = @s_documenttype AND
                     document = @s_document
          ELSE
            BEGIN
              /*  credit memo application:
                    c_appliedamount is negative
                    <> CHECK c_exchamount is positive (debit)
                     = CHECK c_offsetexchamount is positive (debit) */
              IF @s_applicationtype = 'CHECK'
                SELECT @c_crmexchamount = @c_offsetexchamount
              ELSE
                SELECT @c_crmexchamount = @c_exchamount

              UPDATE ar_headers
                 SET applied_amount = IsNull(applied_amount,0) -
                                      IsNull(@c_appliedamount,0),
                     exchanged_applied_amount =
                                      IsNull(exchanged_applied_amount,0) +
                                      IsNull(@c_crmexchamount,0),
                     changed_date = GetDate(),
                     changed_user_id = @s_changeduserid
               WHERE document_type = @s_documenttype AND
                     document = @s_document
            END
        END

       /*  get the next deleted record, if any  */
      FETCH deletedcursor INTO @s_applicationtype, @s_documenttype,
                                @s_document, @c_appliedamount,
                                @c_exchamount, @c_offsetexchamount,
                                @s_changeduserid
    END

  CLOSE deletedcursor
  DEALLOCATE deletedcursor

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_ARApplications]
ON [dbo].[ar_applications] FOR INSERT
AS
BEGIN

  DECLARE @s_applicationtype VARCHAR(6),
          @s_documenttype char(1),
          @s_document VARCHAR(25),
          @s_changeduserid VARCHAR(25),
          @c_appliedamount decimal(18,6),
          @c_exchamount decimal(18,6),
          @c_offsetexchamount decimal(18,6),
          @c_crmexchamount decimal(18,6)

  DECLARE insertedcursor CURSOR FOR
      SELECT application_type, document_type, document, applied_amount,
             exchanged_amount, offset_exchanged_amount, changed_user_id
        FROM inserted

  OPEN insertedcursor

  /*  prime fetch  */
  FETCH insertedcursor INTO @s_applicationtype, @s_documenttype,
                            @s_document, @c_appliedamount,
                            @c_exchamount, @c_offsetexchamount,
                            @s_changeduserid

   WHILE @@fetch_status = 0

    BEGIN
       /*  any fetch status other than 0 will stop the loop  */

       /*  don't mess with document applied amount for overpayments */
      IF @s_applicationtype <> 'OVERPY'
        BEGIN
          IF @s_documenttype = 'I'
             /*  invoice application:
                    c_appliedamount is positive
                    c_offsetexchamount is negative (credit)  */
             UPDATE ar_headers
                SET applied_amount = IsNull(applied_amount,0) +
                                     IsNull(@c_appliedamount,0),
                    exchanged_applied_amount =
                                     IsNull(exchanged_applied_amount,0) -
                                     IsNull(@c_offsetexchamount,0),
                    changed_date = GetDate(),
                    changed_user_id = @s_changeduserid
               WHERE document_type = @s_documenttype AND
                     document = @s_document
          ELSE
            BEGIN
              /*  credit memo application:
                    c_appliedamount is negative
                    <> CHECK c_exchamount is positive (debit)
                     = CHECK c_offsetexchamount is positive (debit) */
              IF @s_applicationtype = 'CHECK'
                SELECT @c_crmexchamount = @c_offsetexchamount
              ELSE
                SELECT @c_crmexchamount = @c_exchamount

              UPDATE ar_headers
                 SET applied_amount = IsNull(applied_amount,0) +
                                      IsNull(@c_appliedamount,0),
                     exchanged_applied_amount =
                                      IsNull(exchanged_applied_amount,0) -
                                      IsNull(@c_crmexchamount,0),
                     changed_date = GetDate(),
                     changed_user_id = @s_changeduserid
               WHERE document_type = @s_documenttype AND
                     document = @s_document
            END
        END

       /*  get the next inserted record, if any  */
      FETCH insertedcursor INTO @s_applicationtype, @s_documenttype,
                                @s_document, @c_appliedamount,
                                @c_exchamount, @c_offsetexchamount,
                                @s_changeduserid
    END

  CLOSE insertedcursor
  DEALLOCATE insertedcursor

END
GO
ALTER TABLE [dbo].[ar_applications] ADD CONSTRAINT [pk_ar_applications] PRIMARY KEY NONCLUSTERED  ([application_number], [application_line]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [arapplications_application] ON [dbo].[ar_applications] ([bill_customer], [check_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [arapplications_document] ON [dbo].[ar_applications] ([document], [document_type]) ON [PRIMARY]
GO
