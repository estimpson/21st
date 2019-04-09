SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_employee_direct_deposits] AS
SELECT
	employees.employee,
	employees.direct_deposit,
	employees.dd_account_type direct_deposit_account_type,
	employees.bank_account bank_account_number,
	employees.transit_routing_no transit_routing_number,
	employees.send_email_notification_to send_to_email_contact
FROM
	employees 
GO
