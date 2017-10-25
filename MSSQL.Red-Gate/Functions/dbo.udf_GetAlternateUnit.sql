SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[udf_GetAlternateUnit]
(	@Part varchar(25)
,	@AltUnit char(2)
)
returns char(2)
as
begin
--- <Body>
	/*	Check if unit is valid alternate unit or return primary unit. */
	declare
		@Unit char(2)
	
	set
		@Unit = coalesce
		(	(	select
		 	 		max(@AltUnit)
		 	 	from
		 	 		dbo.part_unit_conversion puc
					join dbo.unit_conversion uc
						on uc.code = puc.code
				where
					puc.part = @Part
					and
					(	uc.unit1 = @AltUnit
						or uc.unit2 = @AltUnit
					)
			)
		,	(	select
		 			pInv.standard_unit
		 		from
		 			dbo.part_inventory pInv
				where
					pInv.part = @Part
		 	)
		)

--- </Body>

---	<Return>
	return
		@Unit
end
GO
