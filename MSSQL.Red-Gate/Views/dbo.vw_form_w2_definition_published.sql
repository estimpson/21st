SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_form_w2_definition_published] AS
SELECT
	w2_form_published.company,
	w2_form_published.calendar_year,
	w2_form_published.employee,
	w2_form_published.file_id,
	companies.company_name 
FROM
	w2_form_published INNER JOIN
	companies ON
		w2_form_published.company = companies.company 
GO
