SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vt_employee_deduction_type_changes] AS
SELECT
	employee_deduction_type_changes.*,
	employee_deduction_types.deduction_type,
	employees.unit
FROM
	employee_deduction_type_changes INNER JOIN
	employees ON
		employee_deduction_type_changes.employee = employees.employee INNER JOIN
	employee_deduction_types ON
		employee_deduction_type_changes.employee = employee_deduction_types.employee AND
		employee_deduction_type_changes.employee_deduction_type_line = employee_deduction_types.employee_deduction_type_line 
GO
