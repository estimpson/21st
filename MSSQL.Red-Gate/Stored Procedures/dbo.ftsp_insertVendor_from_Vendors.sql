SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE	PROCEDURE [dbo].[ftsp_insertVendor_from_Vendors] @vendorCode VARCHAR(15)

as
 BEGIN

--exec   ftsp_insertVendor_from_Vendors 'Nexeo'


DECLARE @destcode varchar(15)

INSERT INTO VENDOR ( code, name, outside_processor, contact,
                                 phone, terms, ytd_sales, balance,
                                 frieght_type, fob, buyer, plant,
                                 ship_via, company, address_1, address_2,
                                 address_3, address_4,
                                 fax, flag, partial_release_update,
                                 default_currency_unit,
                                 empower_flag)
    
   
	                            
   
SELECT vendor ,
       vendor_name ,
       '',
       contacts.last_name+ ', ' + contacts.first_name,
       contacts.phone,
       vendors.hdr_terms,
       0,
       0,
       vendors.hdr_freight_terms,
       '',
       hdr_buyer,
       hdr_location,
       item_freight,
       hdr_buy_unit,
       address_1,
       address_2,
       address_3,
       country,
       fax_phone,
       0,
       '',
       hdr_currency,
       'EMPOWER'
      
FROM		Vendors
JOIN		dbo.contacts ON dbo.vendors.contact_id = dbo.contacts.contact_id
JOIN		dbo.addresses ON vendors.address_id = dbo.addresses.address_id
WHERE	vendor = @vendorcode
AND NOT EXISTS (SELECT 1 FROM vendor WHERE code = @vendorCode)
			
			
			
IF not EXISTS (SELECT 1 FROM destination WHERE destination = @vendorcode)
SELECT	@destcode	= UPPER(@vendorcode	)
ELSE
SELECT	@destcode = UPPER(@vendorcode)+'V'


--SELECT @destcode
--SELECT	@vendorCode


INSERT dbo.destination
        ( destination ,
          name ,
          type ,
          address_1 ,
          address_2 ,
          address_3 ,
          vendor ,
          flag ,
          plant ,
          scheduler ,
          cs_status 
         
        )

SELECT	UPPER(@destcode),
				name,
				'',
				address_1,
				address_2,
				address_3,
				UPPER(@vendorcode),
				0,
				'21st',
				'',
				'Approved'
				
FROM		dbo.vendor
WHERE	code = @vendorCode
AND	NOT EXISTS (SELECT 1 FROM destination WHERE destination = @destcode)

End
		
GO
