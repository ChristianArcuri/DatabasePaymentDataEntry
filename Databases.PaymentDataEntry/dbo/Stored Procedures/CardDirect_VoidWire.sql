CREATE procedure [dbo].[CardDirect_VoidWire] @WireId int
as
BEGIN
  set nocount on;

  BEGIN TRY  
	  BEGIN TRAN

		  exec WebAgent_VoidPaymentDataEntry @WireId, 57 --CARD DIRECT - COLLECTION FAIL 

		  insert into ProcessedWires(WireID) values(@WireId)
	  COMMIT TRAN
  END TRY
  BEGIN CATCH
		if @@TRANCOUNT > 0
		   rollback TRAN;
  END CATCH  

END