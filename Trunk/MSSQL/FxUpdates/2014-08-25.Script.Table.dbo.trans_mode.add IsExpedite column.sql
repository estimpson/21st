
if	columnproperty(object_id('dbo.trans_mode'), 'IsExpedite', 'AllowsNull') is null
	begin
	alter table dbo.trans_mode add IsExpedite int
end

if	columnproperty(object_id('dbo.shipper'), 'ExpediteCode', 'AllowsNull') is null
	begin
	alter table dbo.shipper add ExpediteCode varchar(50) null
end
