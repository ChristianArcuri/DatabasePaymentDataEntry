CREATE PROCEDURE [dbo].[BillPayment_Create_Payveris]
	@CurrentLanguageId int,
	@SenderId int,
	@UserProfileId varchar(30),
	@PayeeId bigint,
	@AccountNumber varchar(20),
	@PaymentAmount money,
	@ProcessingDate datetime,
	@BTPreparationId uniqueidentifier,
	@BillPaymentResult int OUTPUT, -- 0 OK, 500 error
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
END
