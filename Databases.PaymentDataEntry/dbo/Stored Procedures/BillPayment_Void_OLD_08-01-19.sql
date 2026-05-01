CREATE PROCEDURE [dbo].[BillPayment_Void_OLD_08-01-19]
	@BTControl int,
	@CurrentLanguageId int,
	@UserName varchar(15),
	@VoidPaymentResult int OUTPUT, -- 0 OK,1 Was already cancelled,  500 error
	@ErrorCode varchar(10) OUTPUT,
	@UserErrorMessage varchar(300) OUTPUT,
	@LogErrorMessage varchar(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;		   

	DECLARE @BTAgSenderCode varchar(10)
	DECLARE @BTAgSenderId int
	DECLARE @BTAgPayerCode varchar(10)
	DECLARE @BTAgPayerId int
	DECLARE @BTSenderId int
	DECLARE @BTOriAmount money 
	DECLARE @BTOriCurrency char(3) 
	DECLARE @BTCharges money
	DECLARE @BTTaxAmount money 
	DECLARE @BTAgSenderCommission money 
	DECLARE @BTAgPayerCommission money 
	DECLARE @BTReferenceNumber bigint 
	DECLARE @BTAuthCode varchar(10) 
	DECLARE @BTStatus int
	DECLARE @BTStsCancel int
	DECLARE @BTEstPostDateTime datetime
	DECLARE @BTTransactionId uniqueidentifier
	DECLARE @UserProfileId varchar(50)


     SELECT @BTAgSenderCode         = BTAgSenderCode,
	        @BTAgSenderId           = BTAgSenderId,
			@BTAgPayerCode          = BTAgPayerCode,
	        @BTAgPayerId            = BTAgPayerId,
			@BTSenderId				= BTSenderId,
			@BTOriAmount            = BTOriAmount,
	        @BTOriCurrency          = BTOriCurrency,
			@BTCharges              = BTCharges,
			@BTTaxAmount            = BTTaxAmount,
	        @BTAgSenderCommission   = BTAgSenderCommission,
	        @BTAgPayerCommission    = BTAgPayerCommission,
	        @BTReferenceNumber      = BTReferenceNumber,
	        @BTAuthCode             = BTAuthCode,
			@BTStatus               = BTStatus,
			@BTStsCancel            = BTStsCancel,
			@BTEstPostDateTime      = BTEstPostDateTime,
			@BTTransactionId        = BTTransactionId
	FROM SqlMain.WireTransac.dbo.BT_Sales
    WHERE BTControl = @BTControl

    IF @@ROWCOUNT = 0
      BEGIN
	    SET @VoidPaymentResult = 500
		SET @ErrorCode = '' -- it should be defined
		SET @LogErrorMessage  = 'Transaction not found'
	    SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
	    
		RETURN
	  END

    IF ISNULL(@BTStsCancel,0) <> 0
     BEGIN
	   SET @VoidPaymentResult = 1 
	   SET @ErrorCode = '' -- it should be defined
	   SET @LogErrorMessage  = 'Transaction is already cancelled'
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
	   
	   RETURN
	 END

     SET @UserProfileId = @BTAgSenderCode + '_' + CONVERT(varchar,@BTSenderId)

    -------------Call to Payveris to delete the scheduled payment--------------------------------------------
	DECLARE @IsSuccessful bit
	DECLARE @InfoMessage varchar(max)
	DECLARE @ResultCode varchar(10)
	DECLARE @RequestData varchar(max)
	DECLARE @ResponseData varchar(max)
	DECLARE @ConfirmationNumber bigint
	DECLARE @AuthorizationCode varchar(30)
	DECLARE @RequestDate datetime = GETDATE()
	DECLARE @LogId bigint

	IF ISNULL(@BTReferenceNumber,0) > 0
	  BEGIN
		SELECT @IsSuccessful = IsSuccessful,
				@InfoMessage = InfoMessage,
				@ResultCode = CASE WHEN IsSuccessful = 1 THEN '0' ELSE '500' END,
				@RequestData  = RequestData,
				@ResponseData  = ResponseData,
				@ConfirmationNumber = ConfirmationNumber
		FROM SqlClr.dbo.BTPV_DeleteScheduledPayment (@UserProfileId, @BTReferenceNumber)

		EXECUTE SqlClr.dbo.BTSG_ServiceLogs_Create
				   'BTPV_DeleteScheduledPayment'
				  ,@RequestDate
				  ,@IsSuccessful
				  ,@InfoMessage
				  ,@ResultCode
				  ,@RequestData 
				  ,@ResponseData
				  ,0
				  ,@BTTransactionId
				  ,@LogId OUTPUT

		IF @IsSuccessful = 0
			BEGIN
				SET @VoidPaymentResult = 500
				SET @ErrorCode = '' --it should be defined
				SET @LogErrorMessage  = @InfoMessage
				SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
				RETURN
			END
	 END

   SET @AuthorizationCode = CONVERT(varchar, @ConfirmationNumber)
   SET @VoidPaymentResult = 0
   
   EXEC SqlMain.WireTransac.dbo.BT_SaleCancellation
													@BTControl ,
													'NBP', --TranType National Bill Payment
													@BTAgSenderCode,
													@BTAgSenderid,
													@BTAgPayerCode,
													@BTAgPayerid,
													@BTOriAmount,
													@BTOriCurrency,
													@BTCharges,
													@BTTaxAmount,
													@BTAgSenderCommission,
													@BTAgPayerCommission,
													@AuthorizationCode,
													@ResultCode,
													@InfoMessage,
													@UserName,
													@BTStatus 
   
END