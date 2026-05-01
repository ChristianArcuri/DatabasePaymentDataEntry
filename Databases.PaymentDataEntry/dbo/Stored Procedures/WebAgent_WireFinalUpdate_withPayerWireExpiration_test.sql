 --OJO EN PRODUCCION VOLVER A PONER CALCULO DE AVAILABILITY DATE
CREATE PROCEDURE [dbo].[WebAgent_WireFinalUpdate_withPayerWireExpiration_test]
@PinNumber varchar(20),
@CurrentWebLanguageId int,
@CollectionType varchar(20) OUTPUT,
@WireAvailableDate date OUTPUT,
@MsgToShow varchar(max) OUTPUT,
@PayerWireExpirationDays int OUTPUT,
@UpdResult int Output,
@LogErrorMessage varchar(MAX) OUTPUT

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
  DECLARE @AgPayerCode varchar(10)
  DECLARE @WireDatetime datetime
  DECLARE @BranchId int
  DECLARE @TranTypeId int
  DECLARE @SourceApp int
  DECLARE @WireReplacementType int
  DECLARE @StsUserKBA int
  DECLARE @StsUserKBAOk bit
  DECLARE @StsCreditOK bit
  DECLARE @StsRegDataValidResult  int
  DECLARE @IPDetectedState varchar(40)
  DECLARE @WireFromState varchar(40)
 


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
		 @StsSenderPaymentOK      = StsSenderPaymentOK,
		 @AgPayerCode             = AgPayercode,
		 @WebAgentUserId          = WebAgentUserId,
		 @WireDatetime            = WireDatetime,
		 @BranchId                = BranchId,
		 @TranTypeId              = TranTypeId,
		 @SourceApp               = SourceApp,
		 @WireReplacementType     = WireReplacementType,
		 @StsCreditOK             = StsCreditOK,
		 @IPDetectedState         = IPDetectedState,
		 @WireFromState           = WireFromState,
		 @WireTotalAmount         = WireTotalAmount
    FROM Wires
   WHERE PinNumber = @PinNumber
   IF @@ROWCOUNT = 0
      BEGIN
	    SET @LogErrorMessage = 'Could not find wire for pin '+@PinNumber
		SET @UpdResult = 500
		RETURN
	  END

  
  --FASE 3
   SELECT @StsUserKBA = StsUserKBa,
          @StsRegDataValidResult  = StsRegDataValidResult 
     FROM WireSecurity.dbo.WebAgent_Users
    WHERE WebAgentUserId = @WebAgentUserId
   IF @@ROWCOUNT = 0
      BEGIN
	    SET @LogErrorMessage = 'Could not find webagent user '+convert(varchar,@WebAgentUserId)
		SET @UpdResult = 500
		RETURN
	  END
    IF @StsUserKBA = 1 AND @StsRegDataValidResult in (0,1) --Si no pudo validar NO lo retengo
	     SET @StsUserKBAOk = 1
	ELSE BEGIN
	       IF @StsUserKBA = 2 OR @StsRegDataValidResult = 2
	            SET @StsUserKBAOk = 2
		   ELSE SET @StsUserKBAOk = 0
		 END

   SELECT @PayerWireExpirationDays =PayerWireExpiration 
     FROM SqlMain.WireTransac.dbo.AgPayers
	WHERE AgencyCode = @AgPayerCode
	IF @@ROWCOUNT = 0
	   SET @PayerWireExpirationDays = 30 --Parametrizarlo


   SET @InstantAchOK = 0
   IF @SenderPaymentMethodId = 2 --ACH
      BEGIN     
        EXEC WebAgent_InstantAchVerification @WebAgentUserId ,@UserPaymentMethodInfoId ,@WireTotalAmount,@StsFraudCheckOk ,@InstantAchOK  OUTPUT
        PRINT @WebAgentUserId
		PRINT @UserPaymentMethodInfoId
		PRINT @WireTotalAmount
		PRINT @StsFraudCheckOk
		PRINT @InstantAchOK
	  END

  SET @PinElegible = 0
  IF @SenderPaymentMethodId = 3 --Debit Card
     BEGIN
	   SELECT @PinElegible = PinElegible
	     FROM SqlMain.WireTransac.dbo.WebAgent_UserPaymentMethodInfo
		WHERE UserPaymentMethodInfoId = @UserPaymentMethodInfoId
	 END

  SET @OfacHold = 0 
  IF @StsComplianceOk = 0
     BEGIN
	   IF EXISTS (Select * FROM WireCompliance.dbo.Comp_WireOnHold 
	               WHERE WireId = @WireId AND OnHoldReasonId in (4,5) AND Status = 'P') --OFAC
		    SET @OfacHold = 1
	 END

	   --1 Si esta void no cobrar
   IF @StsCancel = 1
      BEGIN
        SET @CollectionType = 'VoidWire'
	  END
   ELSE IF (@SenderPaymentMethodId = 3 AND @PinElegible = 1)                    --tarjetas de Debit Si es elegible para Pin Debit cobrar
        OR (@SenderPaymentMethodId = 3 AND @PinElegible = 0 AND @OfacHold = 1)  --Si esta retenido por OFAC cobrar
		OR (@SenderPaymentMethodId = 4 AND @StsComplianceOk = 0 AND @OfacHold = 1)  --Si esta retenido por OFAC cobrar
		OR (@SenderPaymentMethodId in (4,3) AND @StsComplianceOk = 1)
           BEGIN 
		     SET @CollectionType = 'OnLine'
			 SET @WireReadyToChargeSender = 1
		   END
   ELSE IF (@SenderPaymentMethodId in (3, 4) )
       AND ((@StsComplianceOk = 0 AND  @OfacHold = 0) OR @StsFraudCheckOk = 0  OR @StsCreditOK = 0)  --Si esta retenido x Compliance o Fraude o Limite de Credito	       
	       BEGIN
		     SET @CollectionType = 'Deferred'  
			 --SET @CollectionType = 'OnLine'
			 SET @WireReadyToChargeSender = 0
		   END 
   ELSE IF (@SenderPaymentMethodId = 2) --ACH
            BEGIN
			  IF (@StsComplianceOk = 1 AND @StsFraudCheckOk = 1 AND @StsCreditOK = 1) --Si no esta retenido x nada
			  OR (@StsComplianceOK = 0 AND @OfacHold = 1)        --O esta retenido por OFAC cobrar
			        BEGIN
					  SET @WireReadyToChargeSender = 1
				      IF @InstantAchOK = 1 
						   BEGIN
						     SET @CollectionType = 'InstantACH'
							 SET @StsSenderPaymentOK = 1
						   END
				      ELSE SET @CollectionType = 'PendingACH'
			   	    END
              ELSE BEGIN
			               SET @WireReadyToChargeSender = 0
					           IF @InstantAchOK = 1 
						            BEGIN
						              SET @CollectionType = 'InstantACHDeferred'
							          SET @StsSenderPaymentOK = 1
						            END
				             ELSE SET @CollectionType = 'PendingACHDeferred'
					END
			END
 
 
  
    IF @StsCancel = 1
	   BEGIN
	     SET @WireAvailableDate = NULL
		 SET @MsgToShow = 'No se pudo'
	   END
	ELSE BEGIN  --OJO EN PRODUCCION VOLVER A PONERLO
	        EXEC SQLMAIN.[WireTransac].dbo.CFPB_CalculateWireAvailableDate_3 @WireDatetime, @AgPayerCode, @BranchId,
				                                                                   1, @TranTypeID, @SourceApp, @WireReplacementType,@WireAvailableDate output
				     
		--	SET @WireAvailableDate = dbo.dateonly(getdate())
			IF @StsComplianceOk = 0 --Retenido x compliance
			   BEGIN
	 			 SET @WireAvailableDate = dateadd(dd,1,dbo.DateOnly(getdate()))  --Hacer funcion o ponerlo configurable	     
			   END
			IF @CollectionType = 'PendingACH'  --No se va hasta que no se acredite el ach
			   BEGIN
			     EXEC GetPendingAchAvailableDate @WireAvailableDate OUTPUT
			   END
			IF @StsCreditOK = 0
			   SET @WireAvailableDate = dateadd(dd,1,dbo.DateOnly(getdate()))  --Le sumo 1 dia si quedo retenido por Credito  

            
			--FASE 3.3
			  -- IF @IPDetectedState IS NOT NULL
			  --AND RTRIM(ltrim(@IPDetectedState)) <> ''
			  --AND rtrim(ltrim(@IPDetectedState)) <> rtrim(ltrim(@WireFromState))
			  --    SET @StsComplianceOk = 0  --Va a quedar retenido en el bridge para verificar geolocation

			  EXEC WebAgent_GetConfirmationpageMessageToShow_withKBA_Credit_fase3_3_TranTypeID @StsComplianceOk,@StsFraudCheckOk,@StsUserKBA, @StsCreditOK,@WireAvailableDate,@CurrentWebLanguageId,@TranTypeId,@MsgToShow OUTPUT
	END

	--BEGIN TRAN 
	----FASE 3
	--UPDATE Wires SET WireAvailableDate       = @WireAvailableDate,
	--                 CollectionType          = @CollectionType,
	--				 InstantAchOK            = @InstantAchOK,
	--				 WireReadyToChargeSender = @WireReadyToChargeSender ,
	--				 StsSenderPaymentOK      = @StsSenderPaymentOK,
	--				 StsUserKBAOk            = @StsUserKBAOk
	-- WHERE WireId = @WireId

	-- IF NOT EXISTS (Select * FROM ProcessedWires Where WireId = @WireId)
	--    BEGIN
	--	  INSERT INTO ProcessedWires with(rowlock) (WireID, Done) Values(@WireID, 0)
 --         update BridgeProcessNow with(updlock) set DoItNow = 1  
	--	END

	-- COMMIT TRAN
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


