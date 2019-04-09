SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_installed_modules] AS
SELECT
	installed_modules.installed_module
FROM
	installed_modules 
GO
