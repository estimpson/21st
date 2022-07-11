select
	*
from
	dbo.employee e
where
	e.operator_code = '1417'

select
	*
from
	FT.Users u
where
	u.OperatorCode = '1417'

select
	*
from
	FT.SecurityAccess sa
where
	sa.SecurityID = '823D0C3D-F26E-4881-A16F-1719725F6765'
go

return

create table #temptable
(
	UserID uniqueidentifier
,	OperatorCode varchar(5)
,	LoginName nvarchar(128)
)
insert	into
	#temptable
(
	UserID
,	OperatorCode
,	LoginName
)
values
('{823d0c3d-f26e-4881-a16f-1719725f6765}', '1417', null)

drop table #temptable

create table #temptable
(
	SecurityID uniqueidentifier
,	ResourceID uniqueidentifier
,	Status int
,	Type int
)
insert	into
	#temptable
(
	SecurityID
,	ResourceID
,	Status
,	Type
)
values
('{823d0c3d-f26e-4881-a16f-1719725f6765}', '{eb71ecf5-33e6-40b6-b933-18bf03b1b43f}', 0, 0)
, ('{823d0c3d-f26e-4881-a16f-1719725f6765}', '{0562855d-6294-4590-8cb9-3cf410da48ee}', 0, 0)
, ('{823d0c3d-f26e-4881-a16f-1719725f6765}', '{7888d9d6-e5f7-4dcf-a434-4c410e76e400}', 0, 0)
, ('{823d0c3d-f26e-4881-a16f-1719725f6765}', '{f0702ca9-556f-4b82-82f2-71ec7be256aa}', 0, 0)
, ('{823d0c3d-f26e-4881-a16f-1719725f6765}', '{29f65993-bc98-4f4e-a733-72f904054efd}', 0, 0)
, ('{823d0c3d-f26e-4881-a16f-1719725f6765}', '{7520ee1f-d74e-4e43-83ad-784861f63431}', 0, 0)
, ('{823d0c3d-f26e-4881-a16f-1719725f6765}', '{9e7805d8-d7b7-4429-a6a4-a065a268c531}', 0, 0)
, ('{823d0c3d-f26e-4881-a16f-1719725f6765}', '{08d9cfa5-13b5-4fe7-96b5-ecdb0ced4f04}', 0, 0)

drop table #temptable
go
