SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vt_document_approvers] AS
SELECT
	doc_approvers.document_type,
	doc_approvers.document_id1,
	doc_approvers.document_id2,
	doc_approvers.document_id3,
	vw_workflows.workflow,
	MIN(CASE WHEN ISNULL(doc_approvers.approved, 'N') = 'Y' THEN 'Y' ELSE 'N' END) approved,
	MAX(CASE WHEN ISNULL(doc_approvers.approved, 'N') = 'C' THEN 'Y' ELSE 'N' END) canceled,
	NULL requester,
	MAX(doc_approvers.changed_date) changed_date,
	MAX(doc_approvers.changed_user_id) changed_user_id
FROM
	doc_approvers LEFT OUTER JOIN
	vw_workflows ON
		doc_approvers.document_type = vw_workflows.document_type
GROUP BY
	doc_approvers.document_type,
	doc_approvers.document_id1,
	doc_approvers.document_id2,
	doc_approvers.document_id3,	vw_workflows.workflow
GO
