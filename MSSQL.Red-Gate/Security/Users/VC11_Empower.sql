IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'VC11\Empower')
CREATE LOGIN [VC11\Empower] FROM WINDOWS
GO
CREATE USER [VC11\Empower] FOR LOGIN [VC11\Empower]
GO
