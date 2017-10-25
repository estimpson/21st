SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [custom].[usp_GetChildPartsWithScrap]
as
declare
	@ChildPartsWithScrap table
(	ChildPart varchar(25) primary key
,	UsedInParts varchar(max)
)

insert
	@ChildPartsWithScrap
(	ChildPart
)
select distinct
	xr.ChildPart
from
	FT.XRt xr
where
	xr.XScrap > 1
	and xr.BOMLevel = 1
order by
	xr.ChildPart

declare
	childPartsWithScrap cursor local forward_only for
select
	cpws.ChildPart
from
	@ChildPartsWithScrap cpws

open
	childPartsWithScrap

while
	1 = 1 begin

	declare
		@childPart varchar(25)
	,	@usedInParts varchar(max)
	
	fetch
		childPartsWithScrap
	into
		@childPart
	
	if	@@FETCH_STATUS != 0 begin
		break
	end
	
	set	@usedInParts = ''
	
	select
		@usedInParts = @usedInParts + ', ' + xr.TopPart + ' (' + convert(varchar, xr.XScrap) + ')'
	from
		FT.XRt xr
	where
		xr.XScrap > 1
		and xr.BOMLevel = 1
		and xr.ChildPart = @childPart
	order by
		xr.TopPart
	
	update
		cpws
	set	UsedInParts = substring(@usedInParts, 3, len(@usedInParts))
	from
		@ChildPartsWithScrap cpws
	where
		cpws.ChildPart = @childPart
end

close
	childPartsWithScrap
deallocate
	childPartsWithScrap

select
	[Child Part] = cpws.ChildPart
,   [Used In Parts (Scrap)] = cpws.UsedInParts
from
	@ChildPartsWithScrap cpws
GO
