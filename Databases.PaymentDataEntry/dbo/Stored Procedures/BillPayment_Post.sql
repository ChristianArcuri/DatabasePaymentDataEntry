CREATE PROCEDURE [dbo].[BillPayment_Post]
	@CurrentLanguageId int,
	@BTControl int,
	@UserProfileId varchar(30),
	@PayeeId bigint,
	@ProcessingDate datetime,
	@DeliveryDate datetime OUTPUT,
	@BillPaymentResult int OUTPUT, -- 0 OK, 500 error
	@UserErrorMessage varchar(300) OUTPUT,
	@LogErrorMessage varchar(MAX) OUTPUT,
	@ScheduledPaymentId bigint	OUTPUT,
    @PaymentFrequency varchar(30) OUTPUT,
    @ConfirmationNumber bigint OUTPUT
AS
BEGIN
   
   SET NOCOUNT ON;

   DECLARE @SenderId int
   DECLARE @AccountNumber varchar(20)
   DECLARE @PaymentAmount money
   DECLARE @BTPreparationId uniqueidentifier
   DECLARE @BTAction varchar(30)
   DECLARE @BTProviderResultCode varchar(30)
   DECLARE @BTProviderTimeStamp datetime
   DECLARE @UpdSaleResult int
   DECLARE @BTAgSenderCode varchar(10)	-- NEW
   DECLARE @BTAgPayerCode varchar(10)	-- NEW
   DECLARE @BTBillerId varchar(20)		-- NEW
   DECLARE @BTBillerGroupId int			-- NEW
   DECLARE @BTBillerAddressId int		-- NEW
   DECLARE @BTBillerAddress varchar(200)-- NEW
   DECLARE @CreatedBy varchar(15)		-- NEW

   IF ISNULL(@BTControl, 0) < 0
      OR (ISNULL(@UserProfileId, '') = '') 
	  OR (ISNULL(@PayeeId, 0) = 0) 
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
		   @BTAgPayerCode = BTAgPayerCode,
		   @BTAgSenderCode = BTAgSenderCode,
		   @BTBillerId = BTBillerId,
		   @BTBillerGroupId = BTBillerGroupId,
		   @BTBillerAddressId = BTBillerAddressId,
		   @BTBillerAddress = BTBillerAddress,
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

   IF @ProcessingDate IS NULL
	SET @ProcessingDate = GETDATE()

   IF EXISTS (SELECT 1 FROM Wiresearch.dbo.Agencies WHERE TestAgency = 1 AND AgencyCode = @BTAgSenderCode)
   BEGIN
		SET @BillPaymentResult = 500
		SET @UserErrorMessage = 'A testing agency cannot create bill payments.'
		SET @LogErrorMessage = 'A testing agency cannot create bill payments.'
		SET @ScheduledPaymentId = 0
		SET	@PaymentFrequency = 0
		SET @ConfirmationNumber = 0
		SET	@DeliveryDate = NULL
   END
   ELSE
   BEGIN
	   ----- call Billpayment_Create_Payveris

		EXECUTE BillPayment_Create_Payveris_V2
			@CurrentLanguageId,
			@SenderId,
			@UserProfileId,
			@PayeeId,
			@AccountNumber,
			@PaymentAmount,
			@ProcessingDate,
			@BTPreparationId,
			@BTAgPayerCode,		-- NEW
			@BTBillerId,		-- NEW
			@BTBillerGroupId,	-- NEW
			@BTBillerAddressId,	-- NEW
			@BTBillerAddress,	-- NEW
			@CreatedBy,			-- NEW
			@BillPaymentResult OUTPUT, -- 0 OK, 500 error
			@UserErrorMessage OUTPUT,
			@LogErrorMessage OUTPUT,
			@ScheduledPaymentId OUTPUT,
			@PaymentFrequency OUTPUT,
			@ConfirmationNumber OUTPUT,
			@DeliveryDate OUTPUT
	END

	--------------------- update BT_Sales------------------------------------
	SET @BTAction = CASE WHEN ISNULL(@BillPaymentResult, 500) = 0 THEN 'CONFIRM' ELSE  'FAIL' END
	SET @BTProviderResultCode = CONVERT(varchar, @BillPaymentResult)
	SET @BTProviderTimeStamp = GETDATE()

	EXECUTE SqlMain.WireTransac.dbo.BT_Sales_Update
		@BTControl,
		@BTAction,
		@BTProviderResultCode,
		@LogErrorMessage,
		'',
		@ScheduledPaymentId,
		@ConfirmationNumber,
		'',
		@DeliveryDate,
		@BTProviderTimeStamp,
		'',
		@PayeeId,
		@UpdSaleResult OUTPUT

	IF ISNULL(@UpdSaleResult ,0) <> 0
		BEGIN
			SET @BillPaymentResult = 500
			SET @UserErrorMessage = 'An error ocurred updating the payment' --multilanguage
			SET @LogErrorMessage = 'An error ocurred updating the payment'
		END
END
