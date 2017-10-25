insert
	Fx.Globals
(	Name
,	Value
)
select
	'CycleCount.HoldLostDays'
,	0.0
where
	not exists
		(	select
				*
			from
				Fx.Globals g
			where
				Name = 'CycleCount.HoldLostDays'
		)
go

select
	*
from
	Fx.Globals g
where
	Name = 'CycleCount.HoldLostDays'
