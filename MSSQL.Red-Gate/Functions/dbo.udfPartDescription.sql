SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[udfPartDescription]
(
	@Part varchar(25)
)
returns varchar(255)
as
begin
--- <Body>
declare
	@Description varchar(255)

set	@Description = (select name from dbo.part where part = @Part)

--- </Body>

---	<Return>
	return
		@Description
end
GO
