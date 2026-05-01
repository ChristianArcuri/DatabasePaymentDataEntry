CREATE PROCEDURE dbo.WebAgent_UserPaymentMethodInfo_Inactive
@UserPaymentMethodInfoId int,
@WebAgentUserId int,
@CurrentWebLanguageId int,
@UpdResult int OUTPUT,
@ErrorCode  varchar(10) OUTPUT,
@UserErrorMessage varchar(300) OUTPUT,
@LogErrorMessage varchar(MAX) OUTPUT
AS
BEGIN
   DECLARE @UserID int
   DECLARE @SenderPaymentMethodStatus char(1)

   

   SELECT @UserID = WebAgentUserId,
          @SenderPaymentMethodStatus = SenderPaymentMethodStatus
     FROM SqlMain.WireTransac.dbo.WebAgent_UserPaymentMethodInfo
    WHERE UserPaymentMethodInfoId  = @UserPaymentMethodInfoId
   IF @@ROWCOUNT = 0
       BEGIN
	     SET @UpdResult = 1
         SET @ErrorCode ='10878'
         SET @UserErrorMessage =''
         SET @LogErrorMessage =dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)+' Id:'+convert(varchar,@UserPaymentMethodInfoId)
	     RETURN
	   END

   IF @UserId <> @WebAgentUserId
      BEGIN
	    SET @UpdResult = 1
         SET @ErrorCode ='10879' --Payment Info belong to another user
         SET @UserErrorMessage =''
         SET @LogErrorMessage =dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
		 RETURN
	  END
   IF @SenderPaymentMethodStatus = 'A'
      EXEC SqlMain.WireTransac.dbo.WebAgent_UserPaymentMethodInfo_Inactive @UserPaymentMethodInfoId,@WebAgentUserId

   SET @UpdResult = 0
   SET @ErrorCode =''
   SET @UserErrorMessage =''
   SET @LogErrorMessage =''
END