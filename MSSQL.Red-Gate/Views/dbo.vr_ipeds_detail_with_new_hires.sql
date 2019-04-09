SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vr_ipeds_detail_with_new_hires] AS

-- ipeds_occupational_category1, 2, 3, 4, and 5 contain the
-- occupational category(n) table values - where n is one of 1, 2, 3, 4, 5 -
-- from Appendix A of the IPEDS HR Import Specifications.
-- The occupational category(3) table has the finest level of breakdown
-- (i.e., the most values) so the occupational category(3) values were
-- used as the occupational_category values.

-- Except for the new hire reports, employees terminated as of the end
-- of the reporting period are not to be included on the reports.  The
-- ipeds_calculation_employees table and this view contain terminated employees who
-- were hired during the year so that they can be included on the new hires reports.
SELECT
	ipeds_calculations.ipeds_calculation,
	ipeds_calculations.ipeds_date,
	ipeds_calculation_employees.employee,
	ipeds_calculation_employees.unit,
	ipeds_calculation_employees.employee_location,
	ipeds_calculation_employees.employee_division,
	employees.employee_first_name,
	employees.employee_middle_name,
	employees.employee_last_name,
	ipeds_calculation_employees.employment_type,
	ipeds_calculation_employees.gender,
	CASE ipeds_calculation_employees.gender
		WHEN 'M' THEN 'Men'
		WHEN 'F' THEN 'Women'
		ELSE ''
	END gender_description,
	ipeds_calculation_employees.hire_date,
	ipeds_calculation_employees.ipeds_academic_rank,
	ipeds_academic_ranks.academic_rank_description ipeds_academic_rank_description,
	ipeds_academic_ranks.academic_rank_sort ipeds_academic_rank_sort_order,
	ipeds_calculation_employees.ipeds_annual_amount,
	ipeds_occupational_categories.ipeds_instructional_staff,
	ipeds_occupational_categories.ipeds_instructional_staff_function,
	CASE ipeds_occupational_categories.ipeds_instructional_staff_function
		WHEN '1' THEN 'Exclusively credit'
		WHEN '2' THEN 'Exclusively not-for-credit'
		WHEN '3' THEN 'Combined credit/not-for-credit'
		ELSE ''
	END ipeds_instructional_staff_function_description,
	ipeds_calculation_employees.ipeds_months_worked,
	CASE ipeds_calculation_employees.ipeds_months_worked
		WHEN '1' THEN '12 Months'
		WHEN '2' THEN '11 Months'
		WHEN '3' THEN '10 Months'
		WHEN '4' THEN '9 Months'
		WHEN '5' THEN '< 9 Months'
		ELSE ''
	END months_worked_description,
	ipeds_calculation_employees.ipeds_occupational_category,
	ipeds_occupational_categories.ipeds_occupational_category_description,
	ipeds_occupational_categories.sort_order ipeds_occupational_category_sort_order,
	ipeds_occupational_categories.ipeds_occupational_category1,	-- Combines instructional staff into a single category
																-- Excludes graduate assistants

	ipeds_occupational_categories.ipeds_occupational_category2,	-- Combines library and education services into a single category
																-- Excludes instructional staff and graduate assistants
	CASE ipeds_occupational_category2
		WHEN '' THEN ''
		WHEN '3' THEN 'Library and Student and Academic Affairs and Other Education Services Occupations'
		ELSE ipeds_occupational_category_description
	END ipeds_occupational_category2_description,
	CASE DATALENGTH(ipeds_occupational_category2)
		WHEN 0 THEN ''
		WHEN 1 THEN '0' + ipeds_occupational_category2
		ELSE ipeds_occupational_category2
	END ipeds_occupational_category2_sort_order,

	ipeds_occupational_categories.ipeds_occupational_category3,	-- Finest level of detail

	ipeds_occupational_categories.ipeds_occupational_category4,	-- Populated only for graduate assistants

	ipeds_occupational_categories.ipeds_occupational_category5,	-- Combines instructional staff into a single category
																-- Combines library and education services into a single category
																-- Excludes graduate assistants
	ipeds_calculation_employees.ipeds_race,
	eeoc_races.eeoc_race_description ipeds_race_description,
	eeoc_races.eeoc_sort ipeds_race_sort_order,
	CASE ipeds_calculation_employees.gender
		WHEN 'M' THEN
			CASE ipeds_calculation_employees.ipeds_race
				WHEN 'N' THEN 1
				WHEN 'H' THEN 2
				WHEN 'I' THEN 3
				WHEN 'A' THEN 4
				WHEN 'B' THEN 5
				WHEN 'P' THEN 6
				WHEN 'W' THEN 7
				WHEN 'T' THEN 8
				WHEN 'U' THEN 9
				ELSE 9
			END
		WHEN 'F' THEN
			CASE ipeds_calculation_employees.ipeds_race
				WHEN 'N' THEN 10
				WHEN 'H' THEN 11
				WHEN 'I' THEN 12
				WHEN 'A' THEN 13
				WHEN 'B' THEN 14
				WHEN 'P' THEN 15
				WHEN 'W' THEN 16
				WHEN 'T' THEN 17
				WHEN 'U' THEN 18
				ELSE 18
			END
		ELSE 20
	END ipeds_race_gender,
	ipeds_calculation_employees.ipeds_tenure_status,
	ISNULL(ipeds_tenure_statuses.ipeds_tenure_status_description, '') tenure_status_description,
	ipeds_tenure_statuses.sort_order tenure_status_sort_order,
	ipeds_calculation_employees.termination_date,
	ipeds_calculation_employees.ipeds_full_time,
	ipeds_calculation_employees.pay_type,
	ipeds_calculation_employees.position,
	positions.position_category
FROM
	ipeds_calculations INNER JOIN
	ipeds_calculation_employees ON
		ipeds_calculations.ipeds_calculation = ipeds_calculation_employees.ipeds_calculation INNER JOIN
	employees ON
		employees.employee = ipeds_calculation_employees.employee LEFT OUTER JOIN
	ipeds_academic_ranks ON
		ipeds_calculation_employees.ipeds_academic_rank = ipeds_academic_ranks.academic_rank LEFT OUTER JOIN
ipeds_occupational_categories ON
		ipeds_calculation_employees.ipeds_occupational_category = ipeds_occupational_categories.ipeds_occupational_category LEFT OUTER JOIN
	ipeds_tenure_statuses ON
		ipeds_calculation_employees.ipeds_tenure_status = ipeds_tenure_statuses.ipeds_tenure_status LEFT OUTER JOIN
	employment_types ON
		employment_types.employment_type = ipeds_calculation_employees.employment_type LEFT OUTER JOIN
	positions ON
		ipeds_calculation_employees.position = positions.position LEFT OUTER JOIN
	eeoc_races ON
		ipeds_calculation_employees.ipeds_race = eeoc_race
		AND eeoc_reporting_type = '6'
GO
