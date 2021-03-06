use [fx21stPilot]
go

CREATE NONCLUSTERED INDEX [_dta_index_audit_trail_6_827202047__K5_K3_K2_4_7_15_25_45] ON [dbo].[audit_trail] 
(
	[part] ASC,
	[date_stamp] ASC,
	[serial] ASC
)
INCLUDE ( [type],
[remarks],
[to_loc],
[std_quantity],
[user_defined_status]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_audit_trail_6_827202047__K2_K3_5_15_45] ON [dbo].[audit_trail] 
(
	[serial] ASC,
	[date_stamp] ASC
)
INCLUDE ( [part],
[to_loc],
[user_defined_status]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_827202047_2_5_3] ON [dbo].[audit_trail]([serial], [part], [date_stamp])
go

CREATE NONCLUSTERED INDEX [_dta_index_object_6_567673070__K1_2_3_27_40] ON [dbo].[object] 
(
	[serial] ASC
)
INCLUDE ( [part],
[location],
[std_quantity],
[user_defined_status]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_part_inventory_6_1815677516__K1_4] ON [dbo].[part_inventory] 
(
	[part] ASC
)
INCLUDE ( [standard_unit]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

