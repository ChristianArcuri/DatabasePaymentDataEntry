CREATE PROCEDURE dbo.webagent_FraudCheckReasonCodes_Read
@CurrentWebAgentLanguageId int,
@FraudCheckDecisionReason int,
@UserErrorMessage varchar(255) output,
@LogErrorMessage varchar(1000) output,
@ActionResult int Output

AS
BEGIN
    DECLARE @Errorcode varchar(10)

	SET @LogErrorMessage = ''
	

	SELECT @ErrorCode    = UserShowErrorCode,
	   	   @ActionResult = ActionResult
	  FROM webagent_FraudCheckReasonCodes
 	  WHERE ReasonCode = @FraudCheckDecisionReason
	IF @@ROWCOUNT = 1
	     BEGIN
   	       SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebAgentLanguageId)
		   SET @LogErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
		 END
    ELSE BEGIN
	       SET @ActionResult = 500
		   SET @LogErrorMessage = 'Could not find error msg '+convert(varchar,@FraudCheckDecisionReason)
		   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage ('10876',@CurrentWebAgentLanguageId) --Error		
         END


END
