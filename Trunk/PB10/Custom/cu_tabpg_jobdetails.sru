HA$PBExportHeader$cu_tabpg_jobdetails.sru
forward
global type cu_tabpg_jobdetails from u_tabpg_jobdetails
end type
end forward

global type cu_tabpg_jobdetails from u_tabpg_jobdetails
end type
global cu_tabpg_jobdetails cu_tabpg_jobdetails

on cu_tabpg_jobdetails.create
call super::create
end on

on cu_tabpg_jobdetails.destroy
call super::destroy
end on

type dw_1 from u_tabpg_jobdetails`dw_1 within cu_tabpg_jobdetails
end type

event dw_1::clicked;call super::clicked;
/*	If the clicked column is qty required, it is editable so set the tab. */
if	lower(dwo.Name) = lower("QtyRequired") then
	object.QtyRequired.TabSequence = 10
end if

end event

event dw_1::itemchanged;call super::itemchanged;
/*	Handle quantity required changes for enterring Mattec quantity. */
if	row <= 0 then return
if	lower(dwo.Name) = lower("qtyrequired") then
	boolean saveChange
	saveChange = (MessageBox(gnv_App.iapp_Object.DisplayName, "You have changed the quantity required for this job to " + data + ".  Save changes?", Question!, OkCancel!, 2) = 1)
	if	saveChange then
		n_cst_custom_mes_inventorytrans customMESInventoryTrans
		customMESInventoryTrans = create n_cst_custom_mes_inventorytrans
		
		long WODID
		WODID = object.WODID [row]
		decimal newQtyRequired
		newQtyRequired = dec(data)
		
		customMESInventoryTrans.SetJobQtyRequired(wodid, newQtyRequired)		
		destroy customMESInventoryTrans
	end if
	object.QtyRequired.TabSequence = 0
	refresh()
end if

end event

type gb_1 from u_tabpg_jobdetails`gb_1 within cu_tabpg_jobdetails
end type

type cb_generate from u_tabpg_jobdetails`cb_generate within cu_tabpg_jobdetails
end type

type cbx_print from u_tabpg_jobdetails`cbx_print within cu_tabpg_jobdetails
end type

