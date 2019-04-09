SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vt_employee_address_changes] AS
SELECT
	employee_address_changes.*,
	employees.unit
FROM
	employee_address_changes INNER JOIN
	employees ON
		employee_address_changes.employee = employees.employee 


GO
