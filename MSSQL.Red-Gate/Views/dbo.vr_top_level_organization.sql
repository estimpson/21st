SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vr_top_level_organization] as
WITH organization_top_level AS
(	SELECT
		ledger_organizations.fiscal_year,
		ledger_organizations.ledger,
		ledger_organizations.organization_level top_organization_level,
		ledger_organizations.organization top_organization,
		ledger_organizations.organization_description top_organization_description,
		ledger_organizations.organization_level,
		ledger_organizations.organization,
		ledger_organizations.organization_description,
		ledger_organizations.reports_to_organization_level,
		ledger_organizations.reports_to_organization,
		0 rto_display_order,
		0 AS level,
		convert( varchar(500),REPLACE( STR( row_number() over(order by ledger,fiscal_year,organization_level,organization), 4),' ','0')) sortindex
	FROM
		ledger_organizations
	UNION ALL
	SELECT
		parent.fiscal_year,
		parent.ledger,
		parent.top_organization_level ,
		parent.top_organization ,
		parent.top_organization_description ,
		child.organization_level,
		child.organization,
		child.organization_description,
		child.reports_to_organization,
		child.reports_to_organization_level,
		ledger_organization_levels.display_order - 0 rto_display_order,
		level + 1,
		convert( varchar(500),parent.sortindex + '_' + REPLACE( STR( row_number() over(order by child.ledger,child.fiscal_year,child.organization_level,child.organization), 4),' ','0')) sortindex
	FROM
		organization_top_level parent INNER JOIN
		ledger_organizations child ON
			parent.fiscal_year = child.fiscal_year AND
			parent.ledger = child.ledger AND
			parent.organization_level = child.reports_to_organization_level AND
			parent.organization = child.reports_to_organization INNER JOIN
		ledger_organization_levels ON
			ledger_organization_levels.fiscal_year = child.fiscal_year AND
			ledger_organization_levels.ledger = child.ledger AND	
			ledger_organization_levels.organization_level = child.organization_level
)
SELECT
	fiscal_year,
	ledger,
	top_organization_level,
	top_organization,
	top_organization_description,
	organization_level,
	organization,
	organization_description,
	reports_to_organization_level,
	reports_to_organization,
	rto_display_order,
	level,
	sortindex
FROM
	organization_top_level 
GO
