
/*	Insert default shipping-packaging rules. */

insert
	Fx.Globals
(	Name
,	Value
)
select
	Name = 'Shipping_PartPackaging.AllowAllAlternates'
,	Value = convert(bit, 0)
where
	not exists
		(	select
				*
			from
				Fx.Globals g
			where
				g.Name = 'Shipping_PartPackaging.AllowAllAlternates'
		)

insert
	Fx.Globals
(	Name
,	Value
)
select
	Name = 'Shipping_PartPackaging.AllowButWarnAllAlternates'
,	Value = convert(bit, 1)
where
	not exists
		(	select
				*
			from
				Fx.Globals g
			where
				g.Name = 'Shipping_PartPackaging.AllowButWarnAllAlternates'
		)

insert
	Fx.Globals
(	Name
,	Value
)
select
	Name = 'Shipping_PartPackaging.AllowEmptyOrNull'
,	Value = convert(bit, 0)
where
	not exists
		(	select
				*
			from
				Fx.Globals g
			where
				g.Name = 'Shipping_PartPackaging.AllowEmptyOrNull'
		)

insert
	Fx.Globals
(	Name
,	Value
)
select
	Name = 'Shipping_PartPackaging.AllowButWarnEmptyOrNull'
,	Value = convert(bit, 1)
where
	not exists
		(	select
				*
			from
				Fx.Globals g
			where
				g.Name = 'Shipping_PartPackaging.AllowButWarnEmptyOrNull'
		)
go

select
	*
from
	FX.Globals g
go
