CREATE PROCEDURE [dbo].[BillPaymentCFP_Post]
		@CurrentLanguageId int,
	@BTControl int,
	@DeliveryDate datetime,
	@BTReceiptMessage nvarchar(MAX),
	@BTIsFixedFee bit,
    @BTFee int,
	@BTBillTypeName varchar(200),					
	@ConfirmationNumber varchar(255),
	@CompanyFee int,
	@BillPaymentResult int OUTPUT, -- 0 OK, 500 error
	@UserErrorMessage varchar(300) OUTPUT,
	@LogErrorMessage varchar(MAX) OUTPUT
AS
BEGIN
   
	SET NOCOUNT ON;

	SET @BillPaymentResult = 0
	SET @UserErrorMessage = ''
	SET @LogErrorMessage = ''

	DECLARE @SenderId int
	DECLARE @AccountNumber varchar(20)
	DECLARE @PaymentAmount money
	DECLARE @BTPreparationId uniqueidentifier
	DECLARE @BTAction varchar(30)
	DECLARE @BTProviderResultCode varchar(30)
	DECLARE @BTProviderTimeStamp datetime
	DECLARE @UpdSaleResult int
	DECLARE @BTAgSenderCode varchar(10)
	DECLARE @CreatedBy varchar(15)
	DECLARE @BTSenderServiceAccountId int
	DECLARE @BTAgPayerCode varchar(10) 
	DECLARE @BTBillerId varchar(20)
	DECLARE @BTBillerGroupId int 
	DECLARE @PayeeId bigint
	DECLARE @UpdResult int,
			@SvcAccErrorCode varchar(10),
			@SvcAccUserErrorMessage varchar(300),
			@SvcAccLogErrorMessage varchar(MAX)

	IF (ISNULL(@BTControl, 0) < 0)
	BEGIN
		SET @BillPaymentResult = 500
		SET @UserErrorMessage = 'An error ocurred posting the payment' --multilanguage
		SET @LogErrorMessage = 'An error ocurred posting the payment'

		RETURN
	END

    SELECT @BTPreparationId =  BTPreparationId,
	       @AccountNumber = BTAccountNumber,
		   @PaymentAmount = BTDestAmount,
		   @SenderId = BTSenderId,
		   @BTBillerId =BTBillerId , 
		   @BTAgPayerCode  = BTAgPayerCode ,
		   @BTAgSenderCode = BTAgSenderCode,
		   @CreatedBy = BTCreatedBy
	FROM SqlMain.WireTransac.dbo.BT_Sales
	WHERE BTControl = @BTControl

	IF (@BTPreparationId IS NULL)
		OR (ISNULL(@AccountNumber, '') = '')
		OR (ISNULL(@SenderId, 0) = 0)
		OR (ISNULL(@PaymentAmount, 0) <= 0)
	BEGIN
		SET @BillPaymentResult = 500
		SET @UserErrorMessage = 'An error ocurred posting the payment' --multilanguage
		SET @LogErrorMessage = 'An error ocurred posting the payment'

		RETURN
	END
	 
	--------------------- UPDATE BT_Sales------------------------------------
	SET @BTAction = CASE WHEN ISNULL(@BillPaymentResult, 500) = 0 THEN 'CONFIRM' ELSE  'FAIL' END
	SET @BTProviderResultCode = CONVERT(varchar, @BillPaymentResult)
	SET @BTProviderTimeStamp = GETDATE()

	EXECUTE SqlMain.WireTransac.dbo.BT_Sales_Update_CFP
		@BTControl,
		@BTAction,
		@BTProviderResultCode,
		@LogErrorMessage,	
		'',
		null,						--@ScheduledPaymentId,
		@ConfirmationNumber,
		'',
		@DeliveryDate,
		@BTReceiptMessage,
		@BTProviderTimeStamp,
		'',
		null,					--@PayeeId,
		@BTIsFixedFee,
		@BTFee,
		@BTBillTypeName,
		@CompanyFee,
		@UpdSaleResult OUTPUT

	IF ISNULL(@UpdSaleResult ,0) <> 0
	BEGIN
		SET @BillPaymentResult = 500
		SET @UserErrorMessage = 'An error ocurred updating the payment' --multilanguage
		SET @LogErrorMessage = 'An error ocurred updating the payment'
	END



	---------------------------Create SenderServiceAccounts--------------------------------
 

	SELECT TOP 1 @BTSenderServiceAccountId=BTSenderServiceAccountId
	  FROM SqlMain.WireTransac.dbo.BT_SenderServiceAccounts 
	 WHERE BTSenderId			= @SenderId 
	   AND BTAgPayerCode		= @BTAgPayerCode 
	   AND BTBillerId			= @BTBillerId
	   AND (BTBillerGroupId IS NULL OR BTBillerGroupId = @BTBillerGroupId)
	   AND BTAccountNumber	= @AccountNumber
	IF @@ROWCOUNT = 0
	BEGIN
		EXEC BillPayment_BT_SenderServiceAccounts_Insert @SenderId, @BTAgPayerCode, @BTBillerId, @BTBillerGroupId, null, null, @AccountNumber, @PayeeId, @CreatedBy
	END ELSE
	BEGIN
		EXEC BillPayment_BT_SenderServiceAccounts_UpdateAccount @CurrentLanguageId, @BTSenderServiceAccountId, null, null, @PayeeId, @CreatedBy, 
																@UpdResult OUTPUT, @SvcAccErrorCode OUTPUT, @SvcAccUserErrorMessage OUTPUT, @SvcAccLogErrorMessage OUTPUT
	END



END