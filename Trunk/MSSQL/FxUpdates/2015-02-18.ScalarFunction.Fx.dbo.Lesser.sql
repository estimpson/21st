
/*
Create ScalarFunction.Fx.dbo.Lesser.sql
*/

--use Fx
--go

if	objectproperty(object_id('dbo.Lesser'), 'IsScalarFunction') = 1 begin
	drop function dbo.Lesser
end
go

create function dbo.Lesser
(	@Value1 numeric(38,19)
,	@Value2 numeric(38,19)
)
returns numeric(38,19)
as
begin
--- <Body>

--- </Body>

---	<Return>
	return
		case
			when @Value2 is null then @Value1
			when @Value1 is null or @Value1 < @Value2 then @Value1
			else @Value2
		end
end
go

