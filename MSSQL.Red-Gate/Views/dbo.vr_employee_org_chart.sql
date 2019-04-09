SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vr_employee_org_chart] as
WITH organization_top_level AS
(	SELECT
		positions.position top_position,
		positions.position_description top_position_description,
		positions.position,
		positions.position_description,
		positions.reports_to_position,
		0 AS level,
		convert( varchar(500),REPLACE( STR( row_number() over(order by positions.position), 4),' ','0')) sortindex
	FROM
		positions
		WHERE reports_to_position is null OR reports_to_position = ''
	UNION ALL
	SELECT
		parent.top_position,
		parent.top_position_description,
		child.position,
		child.position_description,
		child.reports_to_position,
		level + 1,
		convert( varchar(500),parent.sortindex + '_' + REPLACE( STR( row_number() over(order by child.position), 4),' ','0')) sortindex
	FROM
		organization_top_level AS parent
		INNER JOIN positions AS child ON
			parent.position = child.reports_to_position
)
SELECT
	top_position,
	top_position_description,
	position,
	position_description,
	reports_to_position,
	level,
	sortindex
FROM
	organization_top_level 
GO
