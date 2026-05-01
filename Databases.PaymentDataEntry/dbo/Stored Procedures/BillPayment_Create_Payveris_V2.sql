CREATE PROCEDURE [dbo].[BillPayment_Create_Payveris_V2]
	@CurrentLanguageId int,
	@SenderId int,
	@UserProfileId varchar(30),
	@PayeeId bigint,
	@AccountNumber varchar(20),
	@PaymentAmount money,
	@ProcessingDate datetime,
	@BTPreparationId uniqueidentifier,
	@BTAgPayerCode varchar(10),		-- NEW
	@BTBillerId varchar(20),		-- NEW
	@BTBillerGroupId int,			-- NEW
	@BTBillerAddressId bigint,			-- NEW
    @BTBillerAddress varchar(200),	-- NEW
	@CreatedBy varchar(15),			-- NEW
	@BillPaymentResult int OUTPUT,	-- 0 OK, 500 error
	@UserErrorMessage varchar(300) OUTPUT,
	@LogErrorMessage varchar(MAX) OUTPUT,
	@ScheduledPaymentId bigint	OUTPUT,
    @PaymentFrequency varchar(30) OUTPUT,
    @ConfirmationNumber bigint OUTPUT,
	@DeliveryDate datetime OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

    DECLARE @RequestDate datetime
    DECLARE @LogId int
    DECLARE @ResultCode varchar(10)
   	DECLARE @IsSuccessful bit
	DECLARE @InfoMessage varchar(max)
	DECLARE @ResultMessage varchar(max)
	DECLARE @RequestData varchar(max)
	DECLARE @ResponseData varchar(max)
	DECLARE @AccountCode varchar(30)
	DECLARE @BTSenderServiceAccountId int
	DECLARE @UpdResult int,
			@SvcAccErrorCode varchar(10),
			@SvcAccUserErrorMessage varchar(300),
			@SvcAccLogErrorMessage varchar(MAX)


	SET @AccountCode = 'ACC1_' + CONVERT(varchar, @SenderId)

   ----------------Call Payveris to create a scheduled payment -------------------------
   SET @BillPaymentResult = 0  

   SELECT @IsSuccessful  = IsSuccessful,
	   @ResultCode = CASE WHEN IsSuccessful = 1 THEN '0' ELSE '500' END,
	   @InfoMessage  = InfoMessage,
	   @RequestData = RequestData,
	   @ResponseData = ResponseData,
	   @ScheduledPaymentId = ScheduledPaymentId,
	   @PaymentFrequency = PaymentFrequency,
	   @DeliveryDate  = DeliveryDate,
	   @ConfirmationNumber = ConfirmationNumber
   FROM SqlCLR.dbo.BTPV_SchedulePayment (
	   @UserProfileId,
	   @PayeeId,
	   @AccountCode,
	   @PaymentAmount,
	   @ProcessingDate,
	   @DeliveryDate,
	   '')

   SET @RequestDate = GETDATE()
   EXECUTE SqlCLR.dbo.BTSG_ServiceLogs_Create
				'BTPV_SchedulePayment'
				,@RequestDate
				,@IsSuccessful
				,@InfoMessage
				,@ResultCode
				,@RequestData 
				,@ResponseData
				,0
				,@BTPreparationId
				,@LogId OUTPUT
   

   IF ISNULL(@IsSuccessful, 0) = 0
	BEGIN
		SET @LogErrorMessage = @InfoMessage
		SET @BillPaymentResult = 500
		SET @UserErrorMessage = 'An error ocurred creating the payment'  -- multilanguage?
		RETURN
	END

	SELECT TOP 1 @BTSenderServiceAccountId=BTSenderServiceAccountId
	  FROM SqlMain.WireTransac.dbo.BT_SenderServiceAccounts 
	 WHERE BTSenderId			= @SenderId 
	   AND BTAgPayerCode		= @BTAgPayerCode 
	   AND BTBillerId			= @BTBillerId
	   AND (BTBillerGroupId IS NULL OR BTBillerGroupId = @BTBillerGroupId)
	   AND BTAccountNumber	= @AccountNumber
	IF @@ROWCOUNT = 0
	BEGIN
		EXEC BillPayment_BT_SenderServiceAccounts_Insert @SenderId, @BTAgPayerCode, @BTBillerId, @BTBillerGroupId, @BTBillerAddressId, @BTBillerAddress, @AccountNumber, @PayeeId, @CreatedBy
	END ELSE
	BEGIN
		EXEC BillPayment_BT_SenderServiceAccounts_UpdateAccount @CurrentLanguageId, @BTSenderServiceAccountId, @BTBillerAddressId, @BTBillerAddress, @PayeeId, @CreatedBy, 
																@UpdResult OUTPUT, @SvcAccErrorCode OUTPUT, @SvcAccUserErrorMessage OUTPUT, @SvcAccLogErrorMessage OUTPUT
	END
END
