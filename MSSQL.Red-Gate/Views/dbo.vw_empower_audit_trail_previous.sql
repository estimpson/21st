SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_empower_audit_trail_previous] AS
-- receipts with negative qty
SELECT
	audit_trail.id,
	(SELECT
		TOP 1
		t1.id
	FROM
		audit_trail t1
	WHERE
		t1.serial = audit_trail.serial AND
		t1.po_number = audit_trail.po_number AND
		t1.shipper = audit_trail.shipper AND
		t1.date_stamp < audit_trail.date_stamp AND
		t1.quantity > 0
	ORDER BY
		t1.id DESC
	) previous_id,
	(SELECT
		TOP 1
		t1.id
	FROM
		audit_trail t1
	WHERE
		t1.serial = audit_trail.serial AND
		t1.po_number = audit_trail.po_number AND
		t1.shipper = audit_trail.shipper AND
		t1.date_stamp < audit_trail.date_stamp AND
		t1.quantity > 0
	ORDER BY
		t1.id DESC
	) previous_qty_id
FROM
	audit_trail 
WHERE
	type = 'R' AND
	audit_trail.quantity < 0 AND
	EXISTS (SELECT
				1
			FROM
				audit_trail t1
			WHERE
				t1.serial = audit_trail.serial AND
				t1.po_number = audit_trail.po_number AND
				t1.shipper = audit_trail.shipper AND
				t1.date_stamp < audit_trail.date_stamp AND
				t1.quantity > 0
			)
UNION ALL
-- Are deleting or correcting a previous correction. We need
-- the quantity from it, but we need the other info from a
-- row that's not a correction. 
SELECT
	audit_trail.id,
	(SELECT
		TOP 1
		t1.id
	FROM
		audit_trail t1
	WHERE
		t1.serial = audit_trail.serial AND
		t1.date_stamp < audit_trail.date_stamp AND
		t1.type <> 'T' AND
		t1.type <> 'X'
	ORDER BY
		t1.id DESC
	) previous_id,
	(SELECT
		TOP 1
		t1.id
	FROM
		audit_trail t1
	WHERE
		t1.serial = audit_trail.serial AND
		t1.date_stamp < audit_trail.date_stamp AND
		t1.type <> 'T'
	ORDER BY
		t1.id DESC
	) previous_qty_id
FROM
	audit_trail 
WHERE
	audit_trail.type = 'X' AND
	EXISTS (SELECT
				1
			FROM
				audit_trail t1
			WHERE
				t1.serial = audit_trail.serial AND
				t1.date_stamp < audit_trail.date_stamp AND
				t1.type <> 'T'
			)
UNION ALL
-- Empire has D transactions following Y (Empire scrap)
-- transactions. Both the D and the Y have the same time
-- stamp. If we can find a 'Y' with the same time stamp
-- as the D, then the previous transaction type was Y.
SELECT
	audit_trail.id,
	(SELECT
		TOP 1
		t1.id
	FROM
		audit_trail t1
	WHERE
		t1.serial = audit_trail.serial AND
		t1.date_stamp < audit_trail.date_stamp AND
		t1.type <> 'T'
	ORDER BY
		t1.id DESC
	) previous_id,
	(SELECT
		TOP 1
		t1.id
	FROM
		audit_trail t1
	WHERE
		t1.serial = audit_trail.serial AND
		t1.date_stamp < audit_trail.date_stamp AND
		t1.type <> 'T'
	ORDER BY
		t1.id DESC
	) previous_qty_id
FROM
	audit_trail 
WHERE
	audit_trail.type = 'D' AND
	audit_trail.remarks <> 'Scrap' AND
	audit_trail.status <> 'S' AND
	EXISTS (SELECT
				1
			FROM
				audit_trail t1
			WHERE
				t1.serial = audit_trail.serial AND
				t1.date_stamp < audit_trail.date_stamp AND
				t1.type <> 'T'
			) AND
	NOT EXISTS (SELECT
				1
			FROM
				audit_trail t1
			WHERE
				t1.serial = audit_trail.serial AND
				t1.date_stamp = audit_trail.date_stamp AND
				t1.type = 'Y'
			)
GO
