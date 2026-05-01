
CREATE PROCEDURE BillPayment_Validate_with_Presentment
	@CurrentLanguageId int,
	@AgSendercode varchar(10),
	@AgPayerCode varchar(10),
	@SenderId int,
	@SndFirstName varchar(50),
	@SndLast1 varchar(50),
	@SndLast2 varchar(50),
	@SndAddress varchar(50),
	@SndCountry varchar(3),
	@SndState varchar(30),
	@SndCity varchar(40),
	@SndZip varchar(15),
	@BillerId bigint,
	@BillerGroupId  bigint,
	@BillerName varchar(150),
	@BillingAddress varchar(50),
	@BillingCountry varchar(3),
	@BillingStateCode varchar(3),
	@BillingCity varchar(40),
	@BillingZip varchar(15),
	@AccountNumber varchar(20),
	@BTPreparationId uniqueidentifier,
	@BillPaymentResult int OUTPUT, -- 0 OK, 500 error, 1 select address, 2 NoMatch or warning
	@UserErrorMessage varchar(300) OUTPUT,
	@LogErrorMessage varchar(MAX) OUTPUT,
	@UserProfileId varchar(30) OUTPUT,
	@PayeeId bigint OUTPUT,
	@BusinessDaysToDeliver int OUTPUT,
	@NextAvailableProcessingDate datetime OUTPUT,
	@NextAvailableDeliveryDate datetime OUTPUT
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

    ---Call Payveris to create user profile if it doesn't exists

	EXEC BillPayment_PayverisUser_Get
		@CurrentLanguageId,
		@AgSendercode,
		@AgPayerCode,
		@SenderId,
		@SndFirstName,
		@SndLast1,
		@SndLast2,
		@SndAddress,
		@SndCountry,
		@SndState,
		@SndCity,
		@SndZip,
		@BTPreparationId,
		@BillPaymentResult OUTPUT, -- 0 OK, 500 error
		@UserErrorMessage OUTPUT,
		@LogErrorMessage OUTPUT,
		@UserProfileId OUTPUT
 
   IF ISNULL(@BillPaymentResult , 500)= 500
      BEGIN
		 RETURN
	  END

    ---Call Payveris to create a payee if it doesn't exists--------------------------------

	EXECUTE BillPayment_PayverisPayee_Get
	   @UserProfileId,
	   @BTPreparationId,
	   @BillerId,
	   @BillerGroupId,
	   @BillerName,
	   @AccountNumber,
	   @BillingAddress,
	   @BillingCountry,
	   @BillingStateCode,
	   @BillingCity,
	   @BillingZip,
	   @CurrentLanguageId,
	   @PayeeId OUTPUT,
	   @BusinessDaysToDeliver OUTPUT,
	   @NextAvailableProcessingDate OUTPUT,
	   @NextAvailableDeliveryDate OUTPUT,
	   @BillPaymentResult OUTPUT, -- 0 OK, 500 error, 1 Select Address, 2 NoMatch or warning 
	   @UserErrorMessage OUTPUT,
	   @LogErrorMessage OUTPUT

	UPDATE Sqlmain.WireTransac.dbo.BT_Sales
		SET BTPayeeId = @PayeeId
	WHERE BTPreparationId = @BTPreparationId
END
