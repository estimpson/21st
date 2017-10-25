update
	o
set	type = null
from
	dbo.object o
where
	coalesce(o.type, '?') not in ('?', 'S')

select
	type, *
from
	dbo.object o
where
	coalesce(o.type, '?') not in ('?', 'S')
