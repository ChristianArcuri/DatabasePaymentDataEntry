
CREATE PROCEDURE [dbo].[BillPayment_Create_OptStatus]
	@CurrentLanguageId INT,
	@BTAgSenderCode VARCHAR(10) ,
	@BTAgPayerCode VARCHAR(10) ,
	@BTSenderId INT OUTPUT,
	@BTSndVersionId INT,
	@SndFirstName VARCHAR(50),
	@SndLast1 VARCHAR(50),
	@SndLast2 VARCHAR(50),
	@SndNoSecLastName BIT,
	@SndPhone VARCHAR(20),
	@SndAddress VARCHAR(50),
	@SndCountry VARCHAR(3),
	@SndState VARCHAR(30),
	@SndCity VARCHAR(40),
	@SndZip VARCHAR(15),
	@OptStatus CHAR(1),
	@OptStatusPromo CHAR(1),
	@BTBillingAddressId BIGINT,
	@BTBillingAddress VARCHAR(200),
	@BTBillingCountry VARCHAR(30),
	@BTBillingCity VARCHAR(100),
	@BTBillingState VARCHAR(40),
	@BTBillingZipCode VARCHAR(15) ,
	@BTBillerId VARCHAR(20) ,
	@BTBillerGroupId VARCHAR(20),
	@BTBillerName VARCHAR(100),
	@BTPayeeId BIGINT,
	@BTAccountNumber VARCHAR(20),
	@BTDeliveryType VARCHAR(2),   -- SD : Same Day, ND : Next Day (see Geraldine notes)
	@PaymentAmount MONEY,
	@ChargesAmount MONEY,
	@BTTaxAmount MONEY,
	@BTAgSenderCommission MONEY,
	@BTAgPayerCommission MONEY,
	@BTImxCommission  MONEY,
	@BTDiscountAmount MONEY,
	@BTCreatedBy VARCHAR(15),
	@BTSourceApp INT ,
	@BTPreparationId UNIQUEIDENTIFIER,
	@BTBillCustomerId int = 0 OUTPUT,
	@BTBillCustomerVersionId int = 0,
	@BTBillCustomerFirstName varchar(30),
	@BTBillCustomerLast1 varchar(30),
	@BTBillCustomerLast2 varchar(30),
	@BTBillCustomerNoSecLastName bit = 0,
	@BTBillCustomerAddress varchar(200),
	@BTBillCustomerCountry varchar(30),
	@BTBillCustomerState varchar(40),
	@BTBillCustomerCity varchar(40),
	@BTBillCustomerZip varchar(15),
	@BTIsPayingBillOnBehalfOf bit,
	@BTIsFixedFee bit = 0,
	@BTFee int = 0,
	@BTBillTypeName varchar(200) = '',
	@BTCancelAllowed bit = 1,
	@BTContributionAmount money = 0,
	@BillPaymentResult INT OUTPUT, -- 0 OK, 500 error
	@UserErrorMessage VARCHAR(300) OUTPUT,
	@LogErrorMessage VARCHAR(MAX) OUTPUT,
	@BTControl INT OUTPUT,
	@BTAgSenderSeq INT OUTPUT
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
	DECLARE @BTTotAmountInv money
	DECLARE @IsCorporateStore bit
	DECLARE @BTAgState varchar(30)
	DECLARE @OperationAvailable bit
   
	DECLARE @MaxOriAmount money   --Monto maximo aceptado para Bill Payments, reunion con Joseph 1/8/2020
	DECLARE @MaxOriAmountCorporate money
	SET @MaxOriAmount = convert(money, WireSearch.[dbo].[fn_GetConfigParam]( 'BTMaxOriAmount'))
	SET @MaxOriAmountCorporate = convert(money, WireSearch.[dbo].[fn_GetConfigParam]( 'BTMaxOriAmountCorporate'))

	SET @BillPaymentResult = 0
	SET @UserErrorMessage = '' 
	SET @LogErrorMessage = ''

	SET @OperationAvailable =  [ImxDirectSecurity].[dbo].[fn_AgencyIsWithinOperatingHours] (@BTAgSenderCode)
	IF @OperationAvailable = 0
	BEGIN
	    SET @BillPaymentResult = 500
		SET @UserErrorMessage = CONCAT(dbo.fnc_EcoMessage_withLanguage ('11741',@CurrentLanguageId), CHAR(13),dbo.fnc_EcoMessage_withLanguage ('11742',@CurrentLanguageId))
		SET @LogErrorMessage  = CONCAT(dbo.fnc_EcoMessage_withLanguage ('11741',@CurrentLanguageId), dbo.fnc_EcoMessage_withLanguage ('11742',@CurrentLanguageId))
		
		RETURN
	END	

	SELECT	@BTAgSenderId = AgencyId,
			@BTOriCurrency = AgCurrencyCode,
			@IsCorporateStore = CAST(CASE WHEN StoreType = 'B' THEN 1 ELSE 0 END AS bit),
			@BTAgState = UPPER(AgState)
	FROM Wiresearch.dbo.Agencies 
	WHERE AgencyCode = @BTAgSenderCode

	IF @IsCorporateStore = 1 AND @PaymentAmount > @MaxOriAmountCorporate AND @BTAgState NOT IN ('OKLAHOMA','ARIZONA','NEW MEXICO')
	BEGIN
		SET @BillPaymentResult = 500
		SET @LogErrorMessage = Wiresearch.dbo.fnc_EcoMessage_withLanguage ('11500' ,1) --Provider does not accept bill payments above ${0}
		SET @LogErrorMessage = REPLACE(@LogErrorMessage,'{0}',CONVERT(varchar,@MaxOriAmountCorporate))
		SET @UserErrorMessage = Wiresearch.dbo.fnc_EcoMessage_withLanguage ('11500' ,@CurrentLanguageId)
		SET @UserErrorMessage = REPLACE(@UserErrorMessage,'{0}',CONVERT(varchar,@MaxOriAmountCorporate))
		RETURN
	END

	IF (@IsCorporateStore = 0 AND @PaymentAmount > @MaxOriAmount) OR 
	   (@IsCorporateStore = 1 AND @PaymentAmount > @MaxOriAmount AND @BTAgState IN ('OKLAHOMA','ARIZONA','NEW MEXICO'))
	BEGIN
		SET @BillPaymentResult = 500
		SET @LogErrorMessage = Wiresearch.dbo.fnc_EcoMessage_withLanguage ('11500' ,1) --Provider does not accept bill payments above ${0}
		SET @LogErrorMessage = REPLACE(@LogErrorMessage,'{0}',CONVERT(varchar,@MaxOriAmount))
		SET @UserErrorMessage = Wiresearch.dbo.fnc_EcoMessage_withLanguage ('11500' ,@CurrentLanguageId)
		SET @UserErrorMessage = REPLACE(@UserErrorMessage,'{0}',CONVERT(varchar,@MaxOriAmount))
		RETURN
	END
	
	SELECT	 @BTControl			= BTControl
			,@BTSenderIdError	= BTSenderId
			,@BTAgSenderSeqError= BTAgSenderSeq
	FROM SqlMain.WireTransac.dbo.BT_Sales
	WHERE  BTPreparationId = @BTPreparationId


	IF EXISTS (SELECT 1 FROM Wiresearch.dbo.Agencies WHERE TestAgency = 1 AND AgencyCode = @BTAgSenderCode)
	BEGIN
		SET @BillPaymentResult = 500
		SET @UserErrorMessage = 'A testing agency cannot create bill payments.'
		SET @LogErrorMessage = 'A testing agency cannot create bill payments.'

		RETURN
	END

	IF ISNULL(@BTControl, 0) > 0
	BEGIN
		SET @BTSenderId		= @BTSenderIdError
		SET @BTAgSenderSeq	= @BTAgSenderSeqError

		EXEC SqlMain.WireTransac.dbo.BT_Sales_Update_OptStatus
			@BTControl,
			@BTAgSenderId,
			@BTSenderId ,
		    @BTSndVersionId, 
			@SndFirstName,
			@SndLast1,
			@SndLast2,
			@SndNoSecLastName,
			@SndPhone,
			@SndAddress,
			@SndCountry,
			@SndState,
			@SndCity,
			@SndZip,
			@OptStatus,
			@OptStatusPromo,
			@BTCreatedBy,
			@BTBillerId,
			@BTBillerName,
			@BTDeliveryType,
			@BTBillingAddressId,
			@BTBillingAddress,
			@BTBillingCountry,
			@BTBillingState,
			@BTBillingZipCode,
			@BTBillerGroupId,
			@BTAccountNumber,
			@PaymentAmount,
			@BTOriCurrency,
			1,
			@PaymentAmount,
			@BTOriCurrency,
			@ChargesAmount,
			@BTTaxAmount,
			@BTAgSenderCommission,
			@BTAgPayerCommission,
			@BTImxCommission,
			@BTDiscountAmount,
			@BTBillCustomerId,
			@BTBillCustomerVersionId,
			@BTBillCustomerFirstName,
			@BTBillCustomerLast1,
			@BTBillCustomerLast2,
			@BTBillCustomerNoSecLastName ,
			@BTBillCustomerAddress ,
			@BTBillCustomerCountry ,
			@BTBillCustomerState ,
			@BTBillCustomerCity ,
			@BTBillCustomerZip,
			@BTIsPayingBillOnBehalfOf,
			@BTIsFixedFee,
			@BTFee,
			@BTBillTypeName,
			@BTCancelAllowed,
			@BTContributionAmount
		RETURN
	END

	--SELECT @BTAgSenderId = AgencyId,
	--     @BTOriCurrency = AgCurrencyCode
	--FROM Wiresearch.dbo.Agencies 
	--WHERE AgencyCode = @BTAgSenderCode

	SELECT	@MerchantId = MerchantId,
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
		,@BTBillCustomerId  OUTPUT  
		,@BTBillCustomerVersionId   
		,@BTBillCustomerFirstName 
		,@BTBillCustomerLast1 
		,@BTBillCustomerLast2 
		,@BTBillCustomerNoSecLastName 
		,@BTBillCustomerAddress
		,@BTBillCustomerCountry
		,@BTBillCustomerState
		,@BTBillCustomerCity
		,@BTBillCustomerZip 
		,@BTIsPayingBillOnBehalfOf 
		,@BTIsFixedFee
		,@BTFee
		,@BTBillTypeName
		,@BTCancelAllowed
		,@BTContributionAmount
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