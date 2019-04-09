SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vr_ipeds_new_hires] AS

-- New hire reports include employees hired during the reporting period
-- even if they terminated during the reporting period.

SELECT
	vr_ipeds_detail_with_new_hires.ipeds_calculation,
	vr_ipeds_detail_with_new_hires.ipeds_date,
	vr_ipeds_detail_with_new_hires.employee,
	vr_ipeds_detail_with_new_hires.unit,
	vr_ipeds_detail_with_new_hires.employee_location,
	vr_ipeds_detail_with_new_hires.employee_division,
	vr_ipeds_detail_with_new_hires.employee_first_name,
	vr_ipeds_detail_with_new_hires.employee_middle_name,
	vr_ipeds_detail_with_new_hires.employee_last_name,
	vr_ipeds_detail_with_new_hires.employment_type,
	vr_ipeds_detail_with_new_hires.gender,
	vr_ipeds_detail_with_new_hires.gender_description,
	vr_ipeds_detail_with_new_hires.hire_date,
	vr_ipeds_detail_with_new_hires.ipeds_academic_rank,
	vr_ipeds_detail_with_new_hires.ipeds_academic_rank_description,
	vr_ipeds_detail_with_new_hires.ipeds_academic_rank_sort_order,
	vr_ipeds_detail_with_new_hires.ipeds_annual_amount,
	vr_ipeds_detail_with_new_hires.ipeds_instructional_staff,
	vr_ipeds_detail_with_new_hires.ipeds_instructional_staff_function,
	vr_ipeds_detail_with_new_hires.ipeds_instructional_staff_function_description,
	vr_ipeds_detail_with_new_hires.ipeds_months_worked,
	vr_ipeds_detail_with_new_hires.months_worked_description,
	vr_ipeds_detail_with_new_hires.ipeds_occupational_category,
	vr_ipeds_detail_with_new_hires.ipeds_occupational_category_description,
	vr_ipeds_detail_with_new_hires.ipeds_occupational_category_sort_order,
	vr_ipeds_detail_with_new_hires.ipeds_occupational_category1,	-- Combines instructional staff into a single category
																	-- Excludes graduate assistants

	vr_ipeds_detail_with_new_hires.ipeds_occupational_category2,	-- Combines library and education services into a single category
																	-- Excludes instructional staff and graduate assistants
	vr_ipeds_detail_with_new_hires.ipeds_occupational_category2_description,
	vr_ipeds_detail_with_new_hires.ipeds_occupational_category2_sort_order,

	vr_ipeds_detail_with_new_hires.ipeds_occupational_category3,	-- Finest level of detail

	vr_ipeds_detail_with_new_hires.ipeds_occupational_category4,	-- Populated only for graduate assistants

	vr_ipeds_detail_with_new_hires.ipeds_occupational_category5,	-- Combines instructional staff into a single category
																	-- Combines library and education services into a single category
																	-- Excludes graduate assistants
	vr_ipeds_detail_with_new_hires.ipeds_race,
	vr_ipeds_detail_with_new_hires.ipeds_race_description,
	vr_ipeds_detail_with_new_hires.ipeds_race_sort_order,
	vr_ipeds_detail_with_new_hires.ipeds_race_gender,
	vr_ipeds_detail_with_new_hires.ipeds_tenure_status,
	vr_ipeds_detail_with_new_hires.tenure_status_description,
	vr_ipeds_detail_with_new_hires.tenure_status_sort_order,
	vr_ipeds_detail_with_new_hires.termination_date,
	vr_ipeds_detail_with_new_hires.ipeds_full_time,
	vr_ipeds_detail_with_new_hires.pay_type,
	vr_ipeds_detail_with_new_hires.position,
	vr_ipeds_detail_with_new_hires.position_category,
	CONVERT(DATETIME, CONVERT(VARCHAR(4), YEAR(vr_ipeds_detail_with_new_hires.ipeds_date) - 1) + '1101') begin_new_hire_date,
	CONVERT(DATETIME, CONVERT(VARCHAR(4), YEAR(vr_ipeds_detail_with_new_hires.ipeds_date)) + '1031') end_new_hire_date
FROM
	vr_ipeds_detail_with_new_hires
WHERE
	vr_ipeds_detail_with_new_hires.hire_date >= CONVERT(DATETIME, CONVERT(VARCHAR(4), YEAR(vr_ipeds_detail_with_new_hires.ipeds_date) - 1) + '1101') AND
	vr_ipeds_detail_with_new_hires.hire_date <= CONVERT(DATETIME, CONVERT(VARCHAR(4), YEAR(vr_ipeds_detail_with_new_hires.ipeds_date)) + '1031')
GO
