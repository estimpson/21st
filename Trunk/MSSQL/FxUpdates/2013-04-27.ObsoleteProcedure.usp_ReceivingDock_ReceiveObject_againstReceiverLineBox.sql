
/*	ObsoleteProcedure.dbo.usp_ReceivingDock_ReceiveObject_againstReceiverLineBox.sql */
--use Fx
--go

if	objectproperty(object_id('dbo.usp_ReceivingDock_ReceiveObject_againstReceiverLineBox'), 'IsProcedure') = 1 begin
	drop procedure dbo.usp_ReceivingDock_ReceiveObject_againstReceiverLineBox
end
go

