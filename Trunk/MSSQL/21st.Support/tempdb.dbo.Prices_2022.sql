drop table tempdb.dbo.Prices_2022
go

create table tempdb.dbo.Prices_2022
(	RowId int not null IDENTITY(1, 1) primary key
,	PartCode varchar(25) null
,	Color varchar(50) null
,	Price numeric(20,6) null
)
go
