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
public function integer setjobqtyrequired (long jobid, decimal newqtyrequired)
public function integer setjobmattecjobnumber (long jobid, string newmattecjobnumber)
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

public function integer setjobqtyrequired (long jobid, decimal newqtyrequired);
//	Read the parameters.
datetime tranDT ; setNull (tranDT)
long	sqlResult, procResult
string	sqlError

//	Attempt to correct pre-object.
declare SetJobQtyRequired procedure for custom.usp_MES_SetJobQtyRequired
	@Operator = :User
,	@WODID = :jobID
,	@NewQtyRequired = :newQtyRequired
,	@TranDT = :tranDT output
,	@Result =:procResult output using TransObject  ;

execute SetJobQtyRequired  ;
sqlResult = TransObject.SQLCode

if	sqlResult <> 0 then
	sqlError = TransObject.SQLErrText
	TransObject.of_Rollback()
	MessageBox(monsys.msg_Title, "Failed on execute, unable to change quantity required.:  {" + String(sqlResult) + "," + String(procResult) + "} " + sqlError)
	return FAILURE
end if

//	Get the result of the stored procedure.
fetch
	SetJobQtyRequired
into
	:tranDT
,	:procResult  ;

if	procResult <> 0 or TransObject.SQLCode <> 0 then
	sqlError = TransObject.SQLErrText
	TransObject.of_Rollback()
	MessageBox(monsys.msg_Title, "Failed on result, unable to change quantity required:  {" + String(sqlResult) + "," + String(procResult) + "} " + sqlError)
	return FAILURE
end if

//	Close procedure and commit.
close SetJobQtyRequired  ;
TransObject.of_Commit()

//	Return.
return SUCCESS

end function

public function integer setjobmattecjobnumber (long jobid, string newmattecjobnumber);
//	Read the parameters.
datetime tranDT ; setNull (tranDT)
long	sqlResult, procResult
string	sqlError

//	Attempt to set mattec job number.
declare SetJobMattecJobNumber procedure for custom.usp_MES_SetJobMattecJobNumber
	@Operator = :User
,	@WODID = :jobID
,	@NewMattecJobNumber = :newMattecJobNumber
,	@TranDT = :tranDT output
,	@Result =:procResult output using TransObject  ;

execute SetJobMattecJobNumber  ;
sqlResult = TransObject.SQLCode

if	sqlResult <> 0 then
	sqlError = TransObject.SQLErrText
	TransObject.of_Rollback()
	MessageBox(monsys.msg_Title, "Failed on execute, unable to set job number.:  {" + String(sqlResult) + "," + String(procResult) + "} " + sqlError)
	return FAILURE
end if

//	Get the result of the stored procedure.
fetch
	SetJobMattecJobNumber
into
	:tranDT
,	:procResult  ;

if	procResult <> 0 or TransObject.SQLCode <> 0 then
	sqlError = TransObject.SQLErrText
	TransObject.of_Rollback()
	MessageBox(monsys.msg_Title, "Failed on result, unable to  set job number:  {" + String(sqlResult) + "," + String(procResult) + "} " + sqlError)
	return FAILURE
end if

//	Close procedure and commit.
close SetJobMattecJobNumber  ;
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

