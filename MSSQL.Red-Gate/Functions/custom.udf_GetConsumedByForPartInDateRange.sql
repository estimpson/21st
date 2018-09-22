SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE function [custom].[udf_GetConsumedByForPartInDateRange]
(	@PartConsumed varchar(25)
,	@FromDT datetime
,	@ToDT datetime
)
returns varchar(max)
as
begin
--- <Body>
	declare
		@ConsumedByPart varchar(max)
	
	select
		@ConsumedByPart = Fx.ToList(distinct bh.PartProduced)
	from
		dbo.BackflushDetails bd
		join dbo.BackflushHeaders bh
			on bh.BackflushNumber = bd.BackflushNumber
	where
		bd.PartConsumed = @PartConsumed
		and bd.RowCreateDT between @FromDT and @ToDT
	
	set @ConsumedByPart = replace(@ConsumedByPart, ', ', ',')
--- </Body>

---	<Return>
	return
		@ConsumedByPart
end
GO
