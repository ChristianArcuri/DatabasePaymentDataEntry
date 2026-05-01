CREATE PROCEDURE [dbo].[WebAgent_FraudCheckStatusUpdate_Fase3]
@PinNumber                    varchar(20),
@FraudCheckTransacID	      Varchar(50)	,
@FraudCheckDecision	          Varchar(20)	,
@FraudCheckDecisionReason     Int	,
@FraudCheckScore	          Int	,
@KBAResult int output ,--0 = OK, 1 = AskSS, 500 Error
@UpdResult	                  Int	Output,
@ErrorCode	                  varchar(10)	Output,
@LogErrorMessage	          varchar(1000)	Output
AS
BEGIN
  DECLARE @WireID int
  DECLARE @CancelReasonId int
  DECLARE @Control int
  DECLARE @WebAgentUserId int
  DECLARE @SenderPaymentMethodId int

  SET @UpdResult = 0 --OK



  SELECT @WireID = WireId ,
         @WebAgentUserId = WebAgentUserId,
		 @SenderPaymentMethodId = w.SenderPaymentMethodId
    FROM Wires as w
   WHERE PinNumber = @PinNumber
  IF @@ROWCOUNT = 0
     BEGIN
	   SET @UpdResult = 500
	   SET @ErrorCode = ''
	   SET @LogErrorMessage = 'Cannot find the wire for pin '+@PinNumber
	   RETURN
	 END

	SET @KBAResult = 0
	--IF @SenderPaymentMethodId = 2 --ACH
	--   BEGIN
	--		IF EXISTS (Select * FROM WireSecurity.dbo.WebAgent_Users
	--						Where WebAgentUserId = @WebAgentUserId
	--						  and StsUserKBA = 0) --Si es el primer giro o no termino el kba
	--		   BEGIN
	--			 EXEC WireSearch.dbo.WebAgent_KBA_InstantID @WebAgentUserId ,@KBAResult  output ,@ErrorCode	Output,@LogErrorMessage Output
	--		   END
	--  END
   UPDATE WireSecurity.dbo.WebAgent_Users SET StsUserKBA = 1
	WHERE WebAgentUserId = @WebAgentUserId
	  AND StsUserKBA = 0


	SELECT @Control = Control
      FROM ProcessedWires
     WHERE WireId = @WireID
	   and dONE = 1
	   and Control IS NOT NULL
	   and Control > 0
	IF @@ROWCOUNT = 1
       BEGIN
	     --Me voy a WireTransac
		 EXEC SqlMain.WireTransac.dbo.WebAgent_FraudCheckStatusUpdate_WireTransac @Control    ,
                                                                                  @FraudCheckTransacID	      	,
                                                                                  @FraudCheckDecision	          	,
                                                                                  @FraudCheckDecisionReason     	,
                                                                                  @FraudCheckScore	          	,
                                                                                  @UpdResult	     Output,
                                                                                  @ErrorCode	     Output,
                                                                                  @LogErrorMessage   Output
		 RETURN
	   END

	if EXISTS (Select * from WebAgent_WireFraudCheck
	            Where WireId = @WireID)
	 BEGIN
	   SET @UpdResult = 500
	   SET @ErrorCode = ''
	   SET @LogErrorMessage = 'FraudCheck already done for pin '+@PinNumber
	   RETURN
	 END

	INSERT INTO dbo.WebAgent_WireFraudCheck    (WireId                    ,FraudCheckTransacId           ,FraudCheckDecision
											   ,FraudCheckDecisionReason  ,FraudCheckScore               ,FraudCheckDate)
										VALUES (@WireId                   ,@FraudCheckTransacId          ,@FraudCheckDecision
											   ,@FraudCheckDecisionReason ,@FraudCheckScore,              getdate())

   IF @FraudCheckDecision ='ACCEPT'
      BEGIN
	    UPDATE Wires SET StsFraudCheckOk = 1
	     WHERE WireId = @WireId
	  END
   ELSE IF (@FraudCheckDecision = 'REJECT')
        OR (@FraudCheckDecision = 'ERROR')
		   BEGIN
		     SET @CancelReasonId = 52 --WEBAGENT - REJECTED BY CYBERSOURCE
		     EXEC dbo.WebAgent_VoidPaymentDataEntry @WireId ,@CancelReasonId 
		   END

	

END