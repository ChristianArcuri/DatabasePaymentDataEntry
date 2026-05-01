
CREATE PROCEDURE [dbo].[WebAgent_ChangeOfBeneficiaryFinalUpdate]
@PinNumber varchar(20),
@OriControl int,
@CurrentWebLanguageId int,
@CollectionType varchar(20) OUTPUT,
@WireAvailableDate date OUTPUT,
@MsgToShow varchar(1000) OUTPUT,
@UpdResult int Output,
@LogErrorMessage varchar(1000) OUTPUT

AS
BEGIN
  DECLARE @StsComplianceOK bit
  DECLARE @OfacHold bit
  DECLARE @InstantAchOK bit
  DECLARE @StsFraudCheckOk bit
  DECLARE @SenderPaymentMethodId int
  DECLARE @UserPaymentMethodInfoId int
  DECLARE @WebAgentUserId int
  DECLARE @WireTotalAmount money
  DECLARE @StsCancel bit
  DECLARE @WireId int
  DECLARE @PinElegible bit
  DECLARE @StsOK bit
  DECLARE @WireReadyToChargeSender bit
  DECLARE @StsSenderPaymentOK bit
  DECLARE @OriAvailableDate datetime,
          @OriPinNUmber varchar(20)


  SET @UpdResult = 0 --OK

 SET @CollectionType = ''
 SET @WireAvailableDate = NULL
 SET @MsgToShow = ''
 SET @OfacHold = 0
 

BEGIN TRY  
  SELECT @WireId                  = WireId,
         @StsCancel               = StsCancel,
         @SenderPaymentMethodId   = SenderPaymentMethodId,
         @StsComplianceOK         = StsComplianceOk,
		 @UserPaymentMethodInfoId = UserPaymentMethodInfoId,
		 @StsFraudCheckOk         = StsFraudCheckOk,
		 @WireReadyToChargeSender = WireReadyToChargeSender,
		 @StsSenderPaymentOK      = StsSenderPaymentOK
    FROM Wires
   WHERE PinNumber = @PinNumber
   IF @@ROWCOUNT = 0
      BEGIN
	    SET @LogErrorMessage = 'Could not find wire for pin '+@PinNumber
		SET @UpdResult = 500
		RETURN
	  END
  
  SELECT @OriAvailableDate = WireAvailableDate,
         @OriPinNUmber     = PinNumber
    FROM SqlMain.WireTransac.dbo.Wires
   WHERE Control =@OriControl
  IF (@@ROWCOUNT = 1)
 AND (@OriPinNUmber = @PinNumber) --Mismo giro original
       BEGIN
	     --Me voy a WireTransac
		 EXEC SqlMain.WireTransac.dbo.WebAgent_ChangeOfBeneficiaryFinalUpdate_WireTransac @OriControl ,
				@CurrentWebLanguageId ,
				@CollectionType  OUTPUT,
				@WireAvailableDate  OUTPUT,
				@MsgToShow  OUTPUT,
				@UpdResult  Output,
				@LogErrorMessage OUTPUT
		 RETURN
	   END
 



  SET @OfacHold = 0 
  IF @StsComplianceOk = 0
     BEGIN
	   IF EXISTS (Select * FROM WireCompliance.dbo.Comp_WireOnHold 
	               WHERE WireId = @WireId AND OnHoldReasonId in (4,5) AND Status = 'P') --OFAC
		    SET @OfacHold = 1
	 END

    SET @CollectionType = 'Replacement'
			
 
  
    IF @StsCancel = 1
	   BEGIN
	     SET @WireAvailableDate = NULL
		 SET @MsgToShow = 'No se pudo'
	   END
	ELSE BEGIN
	        --EXEC SQLMAIN.[WireTransac].dbo.CFPB_CalculateWireAvailableDate_3 @WireDatetime, @AgPayerCode, @BranchId,
				 --                                                                  1, @TranTypeID, @SourceApp, @WireReplacementType,@WireAvailableDate output
				 --    
			SET @WireAvailableDate = dbo.dateonly(getdate())
			IF @StsComplianceOk = 0 --Retenido x compliance
			   BEGIN
	 			 SET @WireAvailableDate = dateadd(dd,2,dbo.DateOnly(getdate()))  --Hacer funcion o ponerlo configurable	     
			   END
		
		    IF @OriAvailableDate > @WireAvailableDate
			   SET @WireAvailableDate = @OriAvailableDate

			IF @StsComplianceOk = 0
			OR @StsFraudCheckOk = 0
				 SET @StsOK = 0
			ELSE SET @StsOK = 1


			EXEC SqlMain.WireTransac.dbo.WebAgent_ChangeOfBeneficiary_GetConfMessageToShow 'N', @StsOK,@WireAvailableDate,@CurrentWebLanguageId,@MsgToShow OUTPUT
	END

	BEGIN TRAN 

	UPDATE Wires SET WireAvailableDate       = @WireAvailableDate,
	                 CollectionType          = @CollectionType
	 WHERE WireId = @WireId

	 IF NOT EXISTS (Select * FROM ProcessedWires Where WireId = @WireId)
	    BEGIN
		  INSERT INTO ProcessedWires with(rowlock) (WireID, Done) Values(@WireID, 0)
          update BridgeProcessNow with(updlock) set DoItNow = 1  
		END

	 COMMIT TRAN
END TRY
BEGIN CATCH
    IF @@TRANCOUNT <> 0
    BEGIN
		ROLLBACK TRAN
    END
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = 'WebAgent_WireFinalUpdate - '+ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	SET @LogErrorMessage = @ErrorMessage
	SET @UpdResult = 500
    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH  
END


