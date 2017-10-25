if	columnproperty(object_id('dbo.destination_shipping'), 'IsAETCRequired', 'AllowsNull') is null
	begin
	alter table dbo.destination_shipping add IsAETCRequired tinyint
end

