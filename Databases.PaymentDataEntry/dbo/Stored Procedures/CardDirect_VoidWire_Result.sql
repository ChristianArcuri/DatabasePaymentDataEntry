CREATE procedure [dbo].[CardDirect_VoidWire_Result] @WireId int,@VoidOK bit OUTPUT
as
BEGIN
  set nocount on;
  DECLARE @CardChargeId int
    set   @VoidOK=0

  BEGIN TRY  
	  BEGIN TRAN

	    SELECT TOP 1 @CardChargeId = r.ResultId
	      FROM Card_CenPosResults as r
			   INNER JOIN WiresTAG as t on r.WireTAG = t.WireTAG
	     WHERE t.Wireid = @WireId
		   AND r.ResponseResult = 0
		 ORDER BY r.ResultId desc
	    IF @@ROWCOUNT = 0
		   BEGIN
		     exec WebAgent_VoidPaymentDataEntry @WireId, 57 --CARD DIRECT - COLLECTION FAIL 
			 SET @VoidOK = 1
			 if not Exists(select * from ProcessedWires where WireID = @WireId)
		        insert into ProcessedWires(WireID) values(@WireId)
		   END 
		ELSE BEGIN
		       EXEC CardDirectChargeOk_ @WireId , @CardChargeId , 2 --CenPos
		     END


		  
	  COMMIT TRAN
  END TRY
  BEGIN CATCH
		if @@TRANCOUNT > 0
		   rollback TRAN;
  END CATCH  

END