SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_employee_emergency_contacts] AS
SELECT
	employee_contacts.employee,
	employee_contacts.employee_emergency_contact_line,
	employee_contacts.contact employee_emergency_contact_relationship,
	employee_contacts.primary_contact primary_emergency_contact,
	contacts.first_name,
	contacts.last_name,
	contacts.fax_phone cell_phone,
	contacts.phone,
	contacts.email_address
FROM
	employee_contacts LEFT OUTER JOIN
	contacts ON
		employee_contacts.contact_id = contacts.contact_id 

GO
