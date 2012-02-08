
/*
Create table type fx21st.dbo.MES_XRt
*/

--use fx21st
--go

if	exists
	(	select
			*
		from
			sys.types t
		where
			t.is_user_defined = 1
			and t.is_table_type = 1
			and t.name = 'MES_XRt'
			and t.schema_id = schema_id('dbo')
	) begin
	drop type
		dbo.MES_XRt
end
go

create type
	dbo.MES_XRt as table
(	RowID int primary key nonclustered
,	Hierarchy varchar(900) unique clustered
,	TopPart varchar(25)
,	ChildPart varchar(25)
,	BOMID int
,	Sequence tinyint
,	BOMLevel tinyint
,	Suffix int
,	XQty numeric(30,12)
,	XScrap numeric(30,12)
,	XSuffix numeric(30,12)
,	SubForBOMID int
,	SubRate numeric(20,6)
)
go

