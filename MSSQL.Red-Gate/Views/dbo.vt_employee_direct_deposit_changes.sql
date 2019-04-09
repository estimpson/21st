SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vt_employee_direct_deposit_changes] AS
SELECT
	employee_direct_deposit_changes.*,
	employees.unit
FROM
	employee_direct_deposit_changes INNER JOIN
	employees ON
		employee_direct_deposit_changes.employee = employees.employee 

GO
