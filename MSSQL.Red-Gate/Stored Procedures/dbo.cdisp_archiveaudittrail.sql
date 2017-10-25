SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[cdisp_archiveaudittrail] (@startdt datetime=null, @enddt datetime=null) as
begin
	--	Declarations
	declare	@sdate varchar(20),
		@edate varchar(20),
		@serial	integer,
		@datestamp datetime
		
	
	if @startdt is null 
		select	@startdt = getdate()
	if @enddt is null
		select	@enddt = getdate()
			
	select	@sdate = convert(varchar(10), @startdt, 102) + ' 00:00:00',
		@edate = convert(varchar(10), @enddt, 102) + ' 23:59:59'
	select	@startdt = convert(datetime, @sdate),
		@enddt = convert(datetime, @edate)

	if (select count(1) from sysobjects where name = 'audit_trail_archive') = 1
	begin
		begin tran

		declare	auditt cursor for
		select	serial, date_stamp
		from	audit_trail
		where	date_stamp >= @startdt 
			and date_stamp <= @enddt
		
		open	auditt
		
		fetch	auditt into @serial, @datestamp

		while	@@fetch_status = 0 
		begin
			if (select count(1) from audit_trail where serial = @serial and date_stamp = @datestamp) = 0 
				insert	into audit_trail_archive
				select	* 
				from	audit_trail
				where	serial = @serial
					and date_stamp <= @datestamp
			
			fetch	auditt into @serial, @datestamp
		end	
		
		close	auditt
		deallocate auditt
/*
		insert	into audit_trail_archive
		select	* 
		from	audit_trail
		where	date_stamp >= @startdt 
			and date_stamp <= @enddt
*/			
		delete	audit_trail
		where	date_stamp >= @startdt 
			and date_stamp <= @enddt
			
		commit tran
	end
	select 0
end
GO
