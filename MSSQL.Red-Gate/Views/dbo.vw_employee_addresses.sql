SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_employee_addresses] AS
SELECT
	employees.employee,
	employees.employee_first_name,
	employees.employee_last_name,
	employees.employee_middle_name,
	employees.home_cell_phone,
	employees.home_phone,
	employees.office_cell_phone,
	employees.office_phone,
	employees.home_email_address,
	employees.email_address office_email_address,
	addresses.address_1,
	addresses.address_2,
	addresses.address_3,
	addresses.city,
	addresses.state,
	addresses.postal_code,
	addresses.country 
FROM
	employees LEFT OUTER JOIN
	addresses ON
		employees.address_id = addresses.address_id 
GO
