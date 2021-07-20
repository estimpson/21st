SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_ASN_Alert]
as
begin

	declare
		@Date1 datetime = dateadd(hour, -8, getdate())
	,	@Date2 datetime = dateadd(minute, -30, getdate())

	declare
		@IgnoreShippers table
	(	ShipperID int
	,	cpCnt1 int
	,	cpCnt2 int
	)

	insert
		@IgnoreShippers
	select
		s.id
	,	coalesce
		(	(	select
					count(distinct sd.customer_part)
				from
					dbo.shipper_detail sd
				where
					sd.shipper = s.id
					and
					(	sd.customer_part like '%52S-%'
						or sd.customer_part like '%45S-%'
					)
				)
			,	0
		)
	,	(	select
				count(distinct sd.customer_part)
			from
				dbo.shipper_detail sd
			where
				sd.shipper = s.id
		)
	from
		dbo.shipper s
		join dbo.edi_setups es
			on es.destination = s.destination
			and es.asn_overlay_group = 'PLX'
	where
		s.date_shipped >= @Date1
		and s.date_shipped <= @Date2
	union
	select
		s.id
	,	0
	,	0
	from
		dbo.shipper s
		join dbo.edi_setups es
			on es.destination = s.destination
			and es.asn_overlay_group = 'PLX'
	where
		s.date_shipped >= @Date1
		and s.date_shipped <= @Date2
		and not exists
		(
			select * from EDI_XML_PLEX_ASN .ASNLines where ShipperID = s.id
		)
	order by
		1

	declare @Shipments table
	(	ShipperID varchar(25)
	,	DateShipped datetime
	,	Operator varchar(50)
	,	Destination varchar(25)
	,	TradingPartnerCode varchar(25)
	,	primary key (ShipperID)
	)

	insert
		@Shipments
	select
		s.id
	,	s.date_shipped
	,	max(e.name)
	,	s.destination
	,	es.trading_partner_code
	from
		dbo.shipper s
		join dbo.edi_setups es
			on s.destination = es.destination
		join dbo.shipper_detail sd
			on s.id = sd.shipper
		left join dbo.employee e
			on sd.operator = e.operator_code
	where
		s.status in
			( 'C', 'Z' )
		and coalesce(es.auto_create_asn, 'N') = 'Y'
		and s.date_shipped >= @Date1
		and s.date_shipped <= @Date2
		and s.type is null
		and not exists
			(	select
					*
				from
					@IgnoreShippers ish
				where
					ish.ShipperID = s.id
					and ish.cpCnt1 = ish.cpCnt2
			)
	group by
		s.id
	,	s.date_shipped
	,	s.destination
	,	es.trading_partner_code

	declare @Exceptions table
	(
		ShipperID int
	,	Destination varchar(25)
	,	DateShipped datetime
	,	Operator varchar(25)
	,	TradingPartnerCode varchar(25)
	,	Notes varchar(max)
	,	FileStatus int not null
	,	primary key (ShipperID)
	)

	insert
		@Exceptions
	(	ShipperID
	,	Destination
	,	DateShipped
	,	Operator
	,	TradingPartnerCode
	,	Notes
	,	FileStatus
	)
	select
		case
			when es.trading_partner_code like '%Mazda%' then
				right((replicate('0', 6) + convert(varchar(20), s.id)), 6)
			else
				convert(varchar(15), s.id)
		end
	,	s.destination
	,	s.date_shipped
	,	max(e.name)
	,	es.trading_partner_code
	,	case
			when sedi.FileStatus = 0 then
				'ASN Sent but not Acknowledged by iConnect'
			when sedi.FileStatus = -1 then
				'Ship Notice Rejected by IConnect'
			when sedi.FileStatus = -2 then
				'Ship Notice Rejected by Customer'
			else
				'ASN Not Sent to iConnect'
		end
	,	coalesce (sedi.FileStatus, -3)
	from
		dbo.Shipping_EDIDocuments sedi
		join dbo.shipper s
			on s.id = sedi.LegacyShipperID
		join dbo.edi_setups es
			on s.destination = es.destination
		join dbo.shipper_detail sd
			on s.id = sd.shipper
		left join dbo.employee e
			on sd.operator = e.operator_code
	where
		s.status in
			( 'Z', 'C' )
		and s.date_shipped >= @Date1
		and s.date_shipped <= @Date2
		and nullif(sedi.OverlayGroup, '') is not null
		and
		(
			isnull(sedi.FileStatus, 0) < 0
			or
			(
				isnull(sedi.FileStatus, 0) = 0
				and datediff(minute, s.date_shipped, getdate()) > 30
			)
		)
		and sedi.LegacyGenerator = 0
		and not exists
			(	select
					*
				from
					EDI_iConnect.FailedASNLog fal
				where
					fal.ShipperID = s.id
					and fal.Status >= coalesce (sedi.FileStatus, -3)
			)
		and exists
			(	select
					*
				from
					@Shipments s1
				where
					s.id = s1.ShipperID
			)			
	group by
		s.id
	,	s.date_shipped
	,	s.destination
	,	es.trading_partner_code
	,	case
			when sedi.FileStatus = 0 then
				'ASN Sent but not Acknowledged by iConnect'
			when sedi.FileStatus = -1 then
				'Ship Notice Rejected by IConnect'
			when sedi.FileStatus = -2 then
				'Ship Notice Rejected by Customer'
			else
				'ASN Not Sent to iConnect'
		end
	,	coalesce (sedi.FileStatus, -3)
	order by
		5
	,	1

	insert
		@Exceptions
	(	ShipperID
	,	Destination
	,	DateShipped
	,	Operator
	,	TradingPartnerCode
	,	Notes
	,	FileStatus
	)
	select
		case
			when es.trading_partner_code like '%Mazda%' then
				right((replicate('0', 6) + convert(varchar(20), s.id)), 6)
			else
				convert(varchar(15), s.id)
		end
	,	s.destination
	,	s.date_shipped
	,	max(e.name)
	,	es.trading_partner_code
	,	'An ASN previously emailed as having an error has been successfully sent to the customer'
	,	sedi.FileStatus
	from
		dbo.Shipping_EDIDocuments sedi
		join dbo.shipper s
			on s.id = sedi.LegacyShipperID
		join dbo.edi_setups es
			on s.destination = es.destination
		join dbo.shipper_detail sd
			on s.id = sd.shipper
		left join dbo.employee e
			on sd.operator = e.operator_code
	where
		s.status in
			( 'Z', 'C' )
		and s.date_shipped <= @Date2
		and nullif(sedi.OverlayGroup, '') is not null
		and sedi.FileStatus = 1
		and sedi.LegacyGenerator = 0
		and exists
			(
				select * from EDI_iConnect.FailedASNLog fal where fal.ShipperID = s.id and fal.Status < 1
			)
	group by
		s.id
	,	s.date_shipped
	,	s.destination
	,	es.trading_partner_code
	,	sedi.FileStatus
	order by
		5
	,	1


	if exists (select 1 from @Exceptions)
	begin

		declare @tableHTML nvarchar(max);

		set @tableHTML
			= N'<H1>ASN Issue Alert</H1>' + N'<table border="1">' + N'<tr><th>TradingPartner</th>'
			+ N'<th>Destination</th><th>ShipperID</th><th>DateShipped</th>' + N'<th>Notes</th></tr>'
			+ cast((
						select
								td = eo.TradingPartnerCode
						,	''
						,	td = eo.Destination
						,	''
						,	td = eo.ShipperID
						,	''
						,	td = eo.DateShipped
						,	''
						,	td = eo.Notes
						from
								@Exceptions eo
						order by
							1
						,	2
						,	3
						for xml path('tr'), type
					) as nvarchar(max)) + N'</table>'
			+ N'Note : For iConnect ASN issues, please log into iExchange WEB and correct the ASN from the draft folder if it exists'
			+ N'if it does not exist, creat the ASN and send to the Trading Partner. If you need assistance, please contact iConnect to assist.';

		exec msdb.dbo.sp_send_dbmail
			@profile_name = 'DBMail'						-- sysname
		,	@recipients = 'tBursley@21stcpc.com'			-- varchar(max)
		,	@copy_recipients = 'estimpson@fore-thought.com' -- varchar(max)
		,	@subject = N'ASN Issue Alert'					-- nvarchar(255)
		,	@body = @tableHTML								-- nvarchar(max)
		,	@body_format = 'HTML'							-- varchar(20)
		,	@importance = 'High'							-- varchar(6)

	end
end
GO
