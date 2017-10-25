SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE function [custom].[fn_Inventory_GetLastCost]
(	@Part varchar(25)
)
returns numeric(20,6)
as
begin
--- <Body>
/*	Return the net weight of a quantity of a part. */
	declare
		@LastCost numeric(20,6)
	
	set @LastCost = coalesce((select	cost
			from
				dbo.audit_trail
			where
				part = @Part
			and	type = 'R'
			and	date_stamp = (Select 
									max(date_stamp) 
								From
									audit_trail
								where
									part = @part 
								and	type ='R')),0)
	
--- </Body>

---	<Return>
	return
		@LastCost
end

GO
