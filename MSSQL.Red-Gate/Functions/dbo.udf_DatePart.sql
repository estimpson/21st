SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[udf_DatePart]
(	@DatePart varchar (9),
	@ArgDT datetime)
returns	integer
begin
	declare @Return integer
	set	@Return =
		case	when @DatePart in ('Year', 'yyyy') then
				datepart (year, @ArgDT)
			when @DatePart in ('yy', 'y') then
				datepart (year, @ArgDT)%100
			when @DatePart in ('Quarter', 'qq', 'q') then
				datepart (quarter, @ArgDT)
			when @DatePart in ('Month', 'mm', 'm') then
				datepart (month, @ArgDT)
			when @DatePart in ('DayofYear', 'dy', 'jj', 'j') then
				datepart (dayofyear, @ArgDT)
			when @DatePart in ('Day', 'dd', 'd') then
				datepart (day, @ArgDT)
			when @DatePart in ('Week', 'wk', 'ww', 'w') then
				datepart (week, @ArgDT)
			when @DatePart in ('Weekday', 'dw', 'kk', 'k') then
				datepart (weekday, @ArgDT)
			when @DatePart in ('Hour', 'hh', 'h') then
				datepart (hour, @ArgDT)
			when @DatePart in ('Minute', 'mi', 'nn', 'n') then
				datepart (minute, @ArgDT)
			when @DatePart in ('Second', 'ss', 's') then
				datepart (second, @ArgDT)
			when @DatePart in ('Millisecond', 'ms', 'lll', 'l') then
				datepart (millisecond, @ArgDT)
		end
	return @Return
end
GO
