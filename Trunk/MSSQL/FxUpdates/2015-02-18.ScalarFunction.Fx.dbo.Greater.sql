
/*
Create ScalarFunction.Fx.dbo.Greater.sql
*/

--use Fx
--go

if	objectproperty(object_id('dbo.Greater'), 'IsScalarFunction') = 1 begin
	drop function dbo.Greater
end
go

create function dbo.Greater
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
			when @Value1 is null or @Value1 > @Value2 then @Value1
			else @Value2
		end
end
go

