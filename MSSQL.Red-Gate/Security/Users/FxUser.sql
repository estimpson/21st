IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'FxUser')
CREATE LOGIN [FxUser] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [FxUser] FOR LOGIN [FxUser]
GO
