HA$PBExportHeader$n_cst_custom_mes_inventorytrans.sru
forward
global type n_cst_custom_mes_inventorytrans from n_cst_fxtrans
end type
end forward

global type n_cst_custom_mes_inventorytrans from n_cst_fxtrans
end type
global n_cst_custom_mes_inventorytrans n_cst_custom_mes_inventorytrans

forward prototypes
public function integer changeletdownrate (long jobid, decimal newletdownrate)
end prototypes

public function integer changeletdownrate (long jobid, decimal newletdownrate);
//	Read the parameters.
datetime tranDT ; setNull (tranDT)
long	sqlResult, procResult
string	sqlError

//	Attempt to correct pre-object.
declare ChangeLetDownRate procedure for custom.usp_MES_ChangeLetDownRate
	@Operator = :User
,	@WODID = :jobID
,	@NewLetDownRate = :newLetDownrate
,	@TranDT = :tranDT output
,	@Result =:procResult output using TransObject  ;

execute ChangeLetDownRate  ;
sqlResult = TransObject.SQLCode

if	sqlResult <> 0 then
	sqlError = TransObject.SQLErrText
	TransObject.of_Rollback()
	MessageBox(monsys.msg_Title, "Failed on execute, unable to change let down rate:  {" + String(sqlResult) + "," + String(procResult) + "} " + sqlError)
	return FAILURE
end if

//	Get the result of the stored procedure.
fetch
	ChangeLetDownRate
into
	:tranDT
,	:procResult  ;

if	procResult <> 0 or TransObject.SQLCode <> 0 then
	sqlError = TransObject.SQLErrText
	TransObject.of_Rollback()
	MessageBox(monsys.msg_Title, "Failed on result, unable to change let down rate:  {" + String(sqlResult) + "," + String(procResult) + "} " + sqlError)
	return FAILURE
end if

//	Close procedure and commit.
close ChangeLetDownRate  ;
TransObject.of_Commit()

//	Return.
return SUCCESS

end function

on n_cst_custom_mes_inventorytrans.create
call super::create
end on

on n_cst_custom_mes_inventorytrans.destroy
call super::destroy
end on

