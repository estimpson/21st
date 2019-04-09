SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_employee_attachments] AS
SELECT
	employee_attachments.employee,
	employee_attachments.employee_attachment_id attachment_id,
	employee_attachments.attachment_description,
	employee_attachments.calendar_year,
	employee_attachments.is_visible_for_employee,
	employee_attachments.file_id
FROM
	employee_attachments
GO
