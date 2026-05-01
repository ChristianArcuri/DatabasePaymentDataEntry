CREATE PROCEDURE [dbo].[BillPayment_Create_OptStatus_OldOct31_2019]
	@CurrentLanguageId int,
	@BTAgSenderCode varchar(10) ,
	@BTAgPayerCode varchar(10) ,
	@BTSenderId int OUTPUT,
	@BTSndVersionId int,
	@SndFirstName varchar(50),
    @SndLast1 varchar(50),
    @SndLast2 varchar(50),
	@SndNoSecLastName bit,
	@SndPhone varchar(20),
	@SndAddress varchar(50),
	@SndCountry varchar(3),
	@SndState varchar(30),
	@SndCity varchar(40),
	@SndZip varchar(15),
	@OptStatus char(1),
	@OptStatusPromo char(1),
	@BTBillingAddressId bigint,
	@BTBillingAddress varchar(200),
	@BTBillingCountry varchar(30),
	@BTBillingCity varchar(100),
	@BTBillingState varchar(40),
	@BTBillingZipCode varchar(15) ,
	@BTBillerId varchar(20) ,
	@BTBillerGroupId varchar(20),
	@BTBillerName varchar(100),
	@BTPayeeId bigint,
	@BTAccountNumber varchar(20),
	@BTDeliveryType varchar(2),   -- SD : Same Day, ND : Next Day (see Geraldine notes)
	@PaymentAmount money,
    @ChargesAmount money,
	@BTTaxAmount money,
    @BTAgSenderCommission money,
    @BTAgPayerCommission money,
    @BTImxCommission  money,
    @BTDiscountAmount money,
	@BTCreatedBy varchar(15),
	@BTSourceApp int ,
	@BTPreparationId uniqueidentifier, 
	@BillPaymentResult int OUTPUT, -- 0 OK, 500 error
	@UserErrorMessage varchar(300) OUTPUT,
	@LogErrorMessage varchar(MAX) OUTPUT,
	@BTControl int OUTPUT,
	@BTAgSenderSeq int OUTPUT
AS
BEGIN
   
   SET NOCOUNT ON;

   DECLARE @BTAgSenderId int
   DECLARE @MerchantId varchar(20)
   DECLARE @TerminalId varchar(20)
   DECLARE @BTBillingAddresWithCity varchar(200)
   DECLARE @BTOriCurrency char(3)
   DECLARE @BTSenderIdError int
   DECLARE @BTAgSenderSeqError int

   SET @BillPaymentResult = 0
   SET @UserErrorMessage = '' 
   SET @LogErrorMessage = ''
   
   SELECT	 @BTControl			= BTControl
			,@BTSenderIdError	= BTSenderId
			,@BTAgSenderSeqError= BTAgSenderSeq
   FROM SqlMain.WireTransac.dbo.BT_Sales
   WHERE  BTPreparationId = @BTPreparationId

   IF ISNULL(@BTControl, 0) > 0
	BEGIN
		--error or  allow to update the row on BT_Sales ?
		--- it should be defined
		SET @BTSenderId = @BTSenderIdError
		SET @BTAgSenderSeq = @BTAgSenderSeqError		
		RETURN
	END

   SELECT @BTAgSenderId = AgencyId,
        @BTOriCurrency = AgCurrencyCode
   FROM Wiresearch.dbo.Agencies 
   WHERE AgencyCode = @BTAgSenderCode

   SELECT @MerchantId = MerchantId,
		@TerminalId = TerminalId
   FROM Wiresearch.dbo.BT_MerchantConfig 
   WHERE BTAgPayerCode = @BTAgPayerCode

   SET @BTBillingAddresWithCity = @BTBillingAddress + ' ' + @BTBillingCity

   ------inserting new payment into BT_Sales---------------------------------

   EXECUTE SqlMain.WireTransac.dbo.BT_Sales_Create_OptStatus
	   'NBP'
	  ,@BTAgSenderCode
	  ,@BTAgSenderId
	  ,@BTAgPayerCode
	  ,@MerchantId
	  ,@TerminalId
	  ,@BTSenderId OUTPUT
	  ,@BTSndVersionId 
	  ,@SndFirstName
	  ,@SndLast1
	  ,@SndLast2
	  ,@SndNoSecLastName
	  ,@SndPhone
	  ,@SndAddress
	  ,@SndCountry
	  ,@SndState
	  ,@SndCity
	  ,@SndZip
	  ,@OptStatus
	  ,@OptStatusPromo
	  ,@BTBillingAddressId
	  ,@BTBillingAddresWithCity 
	  ,@BTBillingCountry
	  ,@BTBillingState
	  ,@BTBillingZipCode
	  ,@BTBillerId
	  ,@BTBillerGroupId
	  ,@BTBillerName
	  ,@BTAccountNumber
	  ,@BTDeliveryType
	  ,@PaymentAmount
	  ,@BTOriCurrency
	  ,1
	  ,@PaymentAmount
	  ,@BTOriCurrency
	  ,@ChargesAmount
	  ,@BTTaxAmount
	  ,@BTAgSenderCommission
	  ,@BTAgPayerCommission
	  ,@BTImxCommission
	  ,@BTDiscountAmount
	  ,@BTCreatedBy
	  ,@BTSourceApp
	  ,@BTPreparationId
	  ,@BTControl OUTPUT
	  ,@BTAgSenderSeq OUTPUT


	IF ISNULL(@BTControl,0) = 0
		BEGIN
			SET @BillPaymentResult = 500
			SET @UserErrorMessage = 'An error ocurred creating the payment' --multilanguage
			SET @LogErrorMessage = 'An error ocurred creating the payment'
			RETURN
		END

END
