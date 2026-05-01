CREATE PROCEDURE [dbo].[WebAgent_AssignPromoCodeToUser]
@WebAgentUserId int,
@PromoCode varchar(20),
@AssignResult int OUTPUT,
@ErrorCode varchar(10) OUTPUT,
@LogErrorMessage varchar(MAX) OUTPUT
AS
BEGIN
  DECLARE @SameSenderId int
  DECLARE @PromotionId int
  DECLARE @AssignRecordId int

  SET @ErrorCode = ''
  SET @LogErrorMessage = ''

  SET @AssignResult = 500

  SELECT @SameSenderId = SameSenderId 
    FROM SqlMain.WireTransac.dbo.Senders 
   WHERE WebAgentUserId = @WebAgentUserId
  IF (@@ROWCOUNT = 0)
  OR (@SameSenderId = 0)
     BEGIN
	   SET @ErrorCode = '10799' --El remitente no tiene SameSenderId
	   SET @AssignResult = 500
	   SET @LogErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)+' WebAgenUserId: '+convert(varchar,@WebAgentUserId)
	   RETURN
	 END
  SELECT @PromotionId = PromotionId
    FROM WirePricing.dbo.CRM_Promotions
   WHERE PromoCode = @PromoCode
     AND PromoStatus = 'A'
	 AND PromoTarget = 'SAMESENDER'
  IF @@ROWCOUNT = 0
     BEGIN
	   SET @ErrorCode = '10800' --La promocion no existe o no esta activa
	   SET @AssignResult = 500
	   SET @LogErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)+' PromoCode '+@PromoCode
	   RETURN
	 END


  EXEC WirePricing.dbo.CRM_PromotionAssignmentSameSenders_Create @PromotionId ,@SameSenderId ,'SMS','', 'WEBAGENT',@AssignRecordId OUTPUT

   SET @AssignResult = 0 --OK

END