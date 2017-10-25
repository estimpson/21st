CREATE TABLE [dbo].[destination]
(
[destination] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vendor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flag] [int] NULL,
[salestax_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[salestax_rate] [numeric] (7, 4) NULL,
[plant] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduler] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_segment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_5] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_6] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_currency_unit] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[show_euro_amount] [smallint] NULL,
[cs_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[region_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom3] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom4] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom5] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom6] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom7] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom8] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom9] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[custom10] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Insert_ShipLocationEmpower]
ON [dbo].[destination] FOR INSERT

AS
BEGIN
   DECLARE @s_shipaddressid varchar(25),
           @s_billaddressid varchar(25),
           @s_customer varchar(25),
           @s_destination varchar(25),
           @s_address1 varchar(50),
           @s_address2 varchar(50),
           @s_address3 varchar(50),
           @s_name varchar(50),
           @i_rowcount int,
           @i_count int

  /*  is there a row in the inserted table?  */
  SELECT @i_rowcount = Count(*) from inserted

  IF @i_rowcount > 0
    BEGIN

      /* select the appropriate columns from the inserted table */
      SELECT @s_customer = Upper(Ltrim(Rtrim(customer))),
             @s_destination = Upper(Ltrim(Rtrim(destination))),
             @s_address1 = address_1,
             @s_address2 = address_2,
             @s_address3 = address_3,
             @s_name = name
        FROM inserted

      IF @s_customer IS NOT NULL AND @s_customer <> ''
         BEGIN
           /* See if this ship location/customer already exists in Empower. */
           SELECT @i_count = Count(*)
             FROM ar_customer_ship_locations
            WHERE ship_location = @s_destination
              AND customer = @s_customer

           IF @i_count = 0
             BEGIN
               /* get an address id and insert a row into addresses */
               EXECUTE GetNextIdentifier 'ADDRESS', 'ADDRESS', @s_shipaddressid OUTPUT

               INSERT INTO ADDRESSES ( address_id, address_1, address_2, 
                                address_3, changed_date, changed_user_id ) 
                       VALUES ( @s_shipaddressid, @s_address1, @s_address2, 
                                @s_address3, GetDate(), 'MONITOR' )

               /* insert a row into the Empower ar_customer_ship_locations table 
                  for the new ship location */
               INSERT INTO ar_customer_ship_locations 
                          ( customer, ship_location, ship_name,
                            ship_address_id, changed_date, changed_user_id, primary_ship_location )
                    VALUES ( @s_customer, @s_destination, @s_name,
                             @s_shipaddressid, GetDate(), 'MONITOR', 'N' )
             END
           ELSE
             BEGIN
               /* ship location/customer exists in Empower database so update it, first
                  get the address id so address can be updated. */
               SELECT @s_shipaddressid = ship_address_id
                 FROM ar_customer_ship_locations
                WHERE ship_location = @s_destination
                  AND customer = @s_customer

               SELECT @s_billaddressid = bill_address_id
                 FROM ar_customers
                WHERE customer = @s_customer

               IF @s_shipaddressid = @s_billaddressid
                 BEGIN
		     /* ship and bill address ID's are the same. uncouple the 
                    ship and bill addresses so that the insert in Monitor 
                    only affects the ship address. */
                   EXECUTE GetNextIdentifier 'ADDRESS', 'ADDRESS', @s_shipaddressid OUTPUT

                   INSERT INTO ADDRESSES ( address_id, address_1, address_2, 
                                    address_3, changed_date, changed_user_id ) 
                           VALUES ( @s_shipaddressid, @s_address1, @s_address2, 
                                    @s_address3, GetDate(), 'MONITOR' )
                   UPDATE ar_customer_ship_locations
                      SET ship_address_id = @s_shipaddressid
                    WHERE ship_location = @s_destination
                      AND customer = @s_customer
                 END
               ELSE
                 BEGIN
                 /* if the ship and bill address ID's are different, we can
                    simply update the address.  */
                   UPDATE addresses 
                      SET address_1 = @s_address1,
                          address_2 = @s_address2,
                          address_3 = @s_address3,
                          changed_date = GetDate(),
                          changed_user_id = 'MONUPD'
                    WHERE address_id = @s_shipaddressid
                 END

               UPDATE ar_customer_ship_locations 
                  SET ship_name = @s_name,
                      changed_date = GetDate(),
                      changed_user_id = 'MONITOR'
                WHERE ship_location = @s_destination
                  AND customer = @s_customer

             END 
         END 
    END
END
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[mtr_destination_u] on [dbo].[destination] for update
as
begin
	-- declarations
	declare @destination varchar(20),
			@cs_status varchar(20),
			@deleted_status varchar(20)

	-- get first updated row
	select	@destination = min(destination)
	from 	inserted

	-- loop through all updated records and if cs_status has been modified, update 
	-- orders with new status
	while(isnull(@destination,'-1') <> '-1')
	begin

		select	@cs_status = cs_status
		from	inserted
		where	destination = @destination

		select	@deleted_status = cs_status
		from	deleted
		where	destination = @destination

		select @cs_status = isnull(@cs_status,'')
		select @deleted_status = isnull(@deleted_status,'')

		if @cs_status <> @deleted_status
			update 	order_header
			set		cs_status = @cs_status
			where 	destination = @destination

		select	@destination = min(destination)
		from 	inserted
		where	destination > @destination

	end
end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Update_ShipLocationEmpower]
ON [dbo].[destination] FOR UPDATE

AS
BEGIN
   DECLARE @s_shipaddressid varchar(25),
           @s_billaddressid varchar(25),
           @s_customer varchar(25),
           @s_oldcustomer varchar(25),
           @s_destination varchar(25),
           @s_address1 varchar(50),
           @s_address2 varchar(50),
           @s_address3 varchar(50),
           @s_name varchar(50),
           @i_rowcount int,
           @i_count int

  /*  is there a row in the updated table?  */
  SELECT @i_rowcount = Count(*) from inserted

  IF @i_rowcount > 0
    BEGIN

      /* select the appropriate columns from the updated table */
      SELECT @s_customer = Upper(Ltrim(Rtrim(inserted.customer))),
             @s_oldcustomer = Upper(Ltrim(Rtrim(deleted.customer))),
             @s_destination = Upper(Ltrim(Rtrim(inserted.destination))),
             @s_address1 = inserted.address_1,
             @s_address2 = inserted.address_2,
             @s_address3 = inserted.address_3,
             @s_name = inserted.name
        FROM inserted, deleted
       WHERE inserted.destination = deleted.destination

      IF @s_customer IS NOT NULL AND @s_customer <> ''
        BEGIN

          /* Update the Empower ar_customer_ship_locations table with the new values */

          IF @s_customer <> @s_oldcustomer
            BEGIN
              /*** Customer has been changed, we have some work to do ***/

              /*  The ship location has been assigned to a new customer in Monitor.
                  Delete the ship location from the old customer in Empower, as long as it is not
                  the primary ship location for that customer in Empower. */
              DELETE FROM ar_customer_ship_locations
               WHERE ship_location = @s_destination
                 AND customer = @s_oldcustomer
                 AND primary_ship_location <> 'Y'

              /*  Now we need to add the ship location to the new customer in Empower. */

              /*  See if this ship location/customer already exists in Empower. */
              SELECT @i_count = Count(*)
                FROM ar_customer_ship_locations
               WHERE ship_location = @s_destination
                 AND customer = @s_customer

              IF @i_count = 0
                BEGIN
                  /* get an address id and insert a row into addresses */
                  EXECUTE GetNextIdentifier 'ADDRESS', 'ADDRESS', @s_shipaddressid OUTPUT

                  INSERT INTO ADDRESSES ( address_id, address_1, address_2, 
                                          address_3, changed_date, changed_user_id ) 
                           VALUES ( @s_shipaddressid, @s_address1, @s_address2, 
                                    @s_address3, GetDate(), 'MONITOR' )

                  /* insert a row into the Empower ar_customer_ship_locations table for the new
                     ship location/customer */
                  INSERT INTO ar_customer_ship_locations 
                             ( customer, ship_location, ship_name,
                               ship_address_id, changed_date, changed_user_id, primary_ship_location )
                      VALUES ( @s_customer, @s_destination, @s_name,
                               @s_shipaddressid, GetDate(), 'MONITOR', 'N' )
                END
              ELSE
                BEGIN
                  /* ship location/customer exists in Empower database so update it, first
                     get the address id so address can be updated. */
                  SELECT @s_shipaddressid = ship_address_id
                    FROM ar_customer_ship_locations
                   WHERE ship_location = @s_destination
                     AND customer = @s_customer

                  SELECT @s_billaddressid = bill_address_id
                    FROM ar_customers
                   WHERE customer = @s_customer

                  IF @s_shipaddressid = @s_billaddressid
                    BEGIN
		        /* ship and bill address ID's are the same. uncouple the 
                       ship and bill addresses so that the insert in Monitor 
                       only affects the ship address. */
                      EXECUTE GetNextIdentifier 'ADDRESS', 'ADDRESS', @s_shipaddressid OUTPUT

                      INSERT INTO ADDRESSES ( address_id, address_1, address_2, 
                                       address_3, changed_date, changed_user_id ) 
                              VALUES ( @s_shipaddressid, @s_address1, @s_address2, 
                                       @s_address3, GetDate(), 'MONITOR' )
                      UPDATE ar_customer_ship_locations
                         SET ship_address_id = @s_shipaddressid
                       WHERE ship_location = @s_destination
                         AND customer = @s_customer
                    END
                  ELSE
                    BEGIN
                    /* if the ship and bill address ID's are different, we can
                       simply update the address.  */
                      UPDATE addresses 
                         SET address_1 = @s_address1,
                             address_2 = @s_address2,
                             address_3 = @s_address3,
                             changed_date = GetDate(),
                             changed_user_id = 'MONUPD'
                       WHERE address_id = @s_shipaddressid
                    END

                  UPDATE ar_customer_ship_locations 
                     SET ship_name = @s_name,
                         changed_date = GetDate(),
                         changed_user_id = 'MONITOR'
                   WHERE ship_location = @s_destination
                     AND customer = @s_customer

                END
            END
          ELSE
            BEGIN
              IF UPDATE(name)
                 /*** Name has been changed, this is much simpler ***/

                 /*  Update the Empower ar_customer_ship_locations table with the new values */
                UPDATE ar_customer_ship_locations 
                   SET ship_name = @s_name,
                       changed_date = GetDate(),
                       changed_user_id = 'MONITOR'
                 WHERE ship_location = @s_destination
                   AND customer = @s_customer

             IF UPDATE(address_1) OR UPDATE(address_2) OR UPDATE(address_3)
               BEGIN
                 /*  Ship Location has been given a new address, get the address identifier 
                     and update the addresses table */
                 SELECT @s_shipaddressid = ship_address_id
                   FROM ar_customer_ship_locations
                  WHERE ship_location = @s_destination
                    AND customer = @s_customer

                  SELECT @s_billaddressid = bill_address_id
                    FROM ar_customers
                   WHERE customer = @s_customer

                  IF @s_shipaddressid = @s_billaddressid
                    BEGIN
		        /* ship and bill address ID's are the same. uncouple the 
                       ship and bill addresses so that the insert in Monitor 
                       only affects the ship address. */
                      EXECUTE GetNextIdentifier 'ADDRESS', 'ADDRESS', @s_shipaddressid OUTPUT

                      INSERT INTO ADDRESSES ( address_id, address_1, address_2, 
                                       address_3, changed_date, changed_user_id ) 
                              VALUES ( @s_shipaddressid, @s_address1, @s_address2, 
                                       @s_address3, GetDate(), 'MONITOR' )
                      UPDATE ar_customer_ship_locations
                         SET ship_address_id = @s_shipaddressid
                       WHERE ship_location = @s_destination
                         AND customer = @s_customer
                    END
                  ELSE
                    BEGIN
                    /* if the ship and bill address ID's are different, we can
                       simply update the address.  */
                      UPDATE addresses 
                         SET address_1 = @s_address1,
                             address_2 = @s_address2,
                             address_3 = @s_address3,
                             changed_date = GetDate(),
                             changed_user_id = 'MONUPD'
                       WHERE address_id = @s_shipaddressid
                    END

               END
            END
        END
   END
END
GO
ALTER TABLE [dbo].[destination] ADD CONSTRAINT [PK__destination__3D5E1FD2] PRIMARY KEY CLUSTERED  ([destination]) ON [PRIMARY]
GO
