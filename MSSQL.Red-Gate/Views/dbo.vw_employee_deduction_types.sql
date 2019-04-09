SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_employee_deduction_types] AS
SELECT
	employee_deduction_types.employee,
	employee_deduction_types.dd_status direct_deposit,
	employee_deduction_types.dd_account_type direct_deposit_account_type,
	employee_deduction_types.bank_account bank_account_number,
	employee_deduction_types.transit_routing_no transit_routing_number,
	employee_deduction_types.deduction_type,
	employee_deduction_types.employee_deduction_type_line,
	employee_deduction_types.begin_date,
	employee_deduction_types.end_date,
	deduction_types.deduction_type_description ,
	deduction_types.allow_employee_edit
FROM
	employee_deduction_types INNER JOIN
	deduction_types ON
		employee_deduction_types.deduction_type = deduction_types.deduction_type 
GO
