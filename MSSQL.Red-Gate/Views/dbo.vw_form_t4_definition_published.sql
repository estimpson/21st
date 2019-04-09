SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_form_t4_definition_published] AS
SELECT
	t4_form_published.company,
	t4_form_published.calendar_year,
	t4_form_published.employee,
	t4_form_published.business_number,
	t4_form_published.province_of_employment,
	t4_form_published.file_id
FROM
	t4_form_published

GO
