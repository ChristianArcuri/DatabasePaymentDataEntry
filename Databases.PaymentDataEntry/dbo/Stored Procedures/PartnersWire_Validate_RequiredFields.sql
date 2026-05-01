-- =============================================
-- Author: Leandro Gordillo
-- CreateDate: 2023-10-10
-- Description:	Validate required fields to create wire on Partners_WireInPreparation
-- =============================================

CREATE PROCEDURE [dbo].[PartnersWire_Validate_RequiredFields]
    @PreparationID UNIQUEIDENTIFIER,
    @AgPayerId INT,
    @BranchId INT,
	@PartnerId INT,
    @Charges MONEY,
    @CreatedBy VARCHAR(15),
    @DestAmount MONEY,
    @DestCurrency Char(3),
    @OriAmount MONEY,
    @OriToDestExRate MONEY,
    @TranTypeID INT,
    @LanguageId INT,
    @AccountNumber VARCHAR(30),
    @OriCurrency CHAR(3),
    @WireTotalAmount MONEY,
    @DeptBankName VARCHAR(60),
    @AccountType INT,
    @BankBranchCode VARCHAR(7),
    @AgSenderCountryDescription VARCHAR(MAX),
    @DestCountryDescription VARCHAR(MAX),
    @AgPayerCode VARCHAR(10),
    @WireStateFee MONEY,
	@ValidResult INT OUTPUT,
    @ErrorCode VARCHAR(10)  OUTPUT,
    @UserErrorMessage VARCHAR(300) OUTPUT
AS
BEGIN
	DECLARE @cashPickUP INT
	DECLARE @bankDeposit INT
    DECLARE @HQCurrencyCode VARCHAR(3)
    DECLARE @HQToOriExRate MONEY = 1
    DECLARE @ReCalcTotalAmount MONEY
    DECLARE @RcCalcDestAmount MONEY
    DECLARE @OtherChg MONEY = 0
    DECLARE @AgencyFee MONEY = 0
    DECLARE @WireSenderPaymentMethodFee MONEY = 0
    DECLARE @CashBackAmount MONEY = 0
    DECLARE @DiscountAmount MONEY = 0
    DECLARE @NeedToRoundDestAmount BIT
	DECLARE @DestAmountMultipleOf MONEY

    SET @HQCurrencyCode = [Wiresearch].[dbo].[fn_GetHQCurrencyCode]()
    SET @HQToOriExRate  = [Wiresearch].dbo.GetExRate2019 (@HQCurrencyCode,@ORiCurrency) 
    SET @ValidResult = 0
	SET @ErrorCode = ''
	SET @UserErrorMessage =  ''	
	SET @cashPickUP = 1
	SET @bankDeposit = 3
    SET @ReCalcTotalAmount =  IsNull(@OriAmount, 0) + IsNull(@Charges, 0) + IsNull(@OtherChg, 0) +
        IsNull(@AgencyFee, 0) + IsNull(@WireStateFee, 0) + IsNull(@WireSenderPaymentMethodFee, 0) + 
        IsNull(@CashBackAmount, 0) - IsNull(@DiscountAmount, 0)

    -- Validate PreparationID (GUID)
    IF (@PreparationID IS NULL)
    BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '100' -- {0} required.
		SET @UserErrorMessage =  REPLACE(dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId),'{0}', 'PreparationId')
        RETURN
    END

    -- Validate branchId
    IF (@BranchId IS NULL)
    BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '11758' -- Branch Id is empty. Enter a value.
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

	-- Validate partnerId
    IF (@PartnerId IS NULL)
    BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '11637' -- The partner must be selected.
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

    -- Validate charges
    IF (@Charges IS NULL OR @Charges < 0)
    BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '1031' -- Please calculate charges first.
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

    -- Validate CreatedBy
    IF (@CreatedBy IS NULL OR LEN(LTRIM(RTRIM(@CreatedBy))) = 0 OR LEN(@CreatedBy) > 15)
    BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '11764' -- CreatedBy is empty. Enter a value.
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END
		
    -- Validar oriAmount
    IF (@OriAmount IS NULL OR @OriAmount < 0)
    BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '11760' -- Error in origin amount.
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

    IF EXISTS (SELECT AgPayerPaymentLimitId FROM [Wiresearch].dbo.AgPayerPaymentLimit WHERE AgPayerCode = @AgPayerCode AND CurrencyCode = @HQCurrencyCode--  @OriCurrency 
	    AND ROUND((PaymentLimit*@HQToOriExRate),2) < @OriAmount  --Convierto Limite a moneda Origen
	    AND TranTypeId in (0,@TranTypeID))
    BEGIN
		SET @ValidResult = 1
	    SET @ErrorCode = '11308' -- Wire amount is higher than Payer Payment Limit
        SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
    RETURN
    END

    IF EXISTS (SELECT AgPayerPaymentLimitId FROM [Wiresearch].dbo.AgPayerPaymentLimit WHERE AgPayerCode = @AgPayerCode
	    AND CurrencyCode = @DestCurrency
	    AND PaymentLimit < @DestAmount
	    AND TranTypeId in (0,@TranTypeID))
        BEGIN
		SET @ValidResult = 1
		SET @ErrorCode = '11308' -- Wire amount is higher than Payer Payment Limit
        SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
    RETURN
    END

    IF EXISTS (SELECT BranchPaymentLimitId FROM [Wiresearch].dbo.BranchPaymentLimit WHERE BranchId = @BranchId
        AND CurrencyCode = @HQCurrencyCode--  @OriCurrency
        AND ROUND((PaymentLimit*@HQToOriExRate),2) < @OriAmount)  --Convierto Limite a moneda Origen
        BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '11309' -- Wire amount is higher than the Selected Branch Payment Limit
        SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
    RETURN
    END

    IF EXISTS (SELECT BranchPaymentLimitId FROM [Wiresearch].dbo.BranchPaymentLimit WHERE BranchId = @BranchId AND CurrencyCode = @DestCurrency AND PaymentLimit < @DestAmount)
        BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '11309' -- Wire amount is higher than the Selected Branch Payment Limit
        SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
    RETURN
    END

    -- Validar oriToDestExRate
    IF (@OriToDestExRate IS NULL OR @OriToDestExRate < 0)
    BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '1706' -- Please enter the Exchange Rate.
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

	-- Validate destAmount
    IF (@destAmount IS NULL OR @destAmount < 0)
    BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '1067' -- Invalid Dest Amount
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

    SELECT @NeedToRoundDestAmount = ISNULL(NeedToRoundDestAmount,0),
		   @DestAmountMultipleOf = ISNULL(DestAmountMultipleOf,0)
	FROM Wiresearch.dbo.AgPayers
	WHERE AgencyId = @AgPayerId

	SET @RcCalcDestAmount = @OriAmount * @OriToDestExRate
	IF @NeedToRoundDestAmount = 1 AND @DestAmountMultipleOf > 0 AND (@DestAmount % @DestAmountMultipleOf) = 0  --- PAYER ATM
	BEGIN
		IF Abs(ROUND(@RcCalcDestAmount, 2) - @DestAmount) > 0.5
		BEGIN
			SET @ValidResult  = 1
			SET @ErrorCode = '10837' -- Invalid Dest Amount
			SET @UserErrorMessage =  dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
			RETURN
		END
	END
	ELSE
	BEGIN
		IF Abs(ROUND(@RcCalcDestAmount, 2) - @DestAmount) > 0.01
		BEGIn
			SET @ValidResult  = 1
			SET @ErrorCode = '10837' -- Invalid Dest Amount
			SET @UserErrorMessage =  dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
			RETURN
		END
	END

	-- Validar Destination Currency
    IF (@DestCurrency IS NULL OR LEN(LTRIM(RTRIM(@DestCurrency))) = 0 OR LEN(@DestCurrency) > 3)
    BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '11069' -- Destination Currency is blank.
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

    -- Validar TranTypeID
    IF (@TranTypeID IS NULL OR (@TranTypeID <> @cashPickUP AND @TranTypeID <> @bankDeposit))
    BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '10820' -- Please Select Pick Up or Bank Deposit 
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

    -- Validate bank details
    IF (@TranTypeID = @bankDeposit AND (@AccountNumber IS NULL OR @AccountNumber = ''))
    BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '10824' -- Please enter the Bank Account Number
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

    IF (@TranTypeID = @bankDeposit AND (@DeptBankName IS NULL OR @DeptBankName = ''))
    BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '10825' -- Please enter the Bank Name 
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

    IF (@TranTypeID = @bankDeposit AND (@AccountType IS NULL OR @AccountType <= 0))
    BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '10826' -- Please enter Account Type 
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

    IF (@TranTypeID = @bankDeposit AND (@BankBranchCode IS NULL OR @BankBranchCode = ''))
    BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '10218' -- This transaction requires a Branch Code. 
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

    -- Validate OriCurrency
    IF @OriCurrency IS NULL OR @OriCurrency = ''
    BEGIN
        SET @ValidResult = 1
        SET @ErrorCode = '10827' -- Origin Currency Code is Blanc
        SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

    IF NOT EXISTS(Select * FROM [Wiresearch].dbo.Geo_Countries WHERE Countryname = @AgSenderCountryDescription AND Currencycode = @OriCurrency)
    BEGIN
        SET @ValidResult = 1
        SET @ErrorCode = '10828' -- Origin Currency Code does not belong to Origin Country
        SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

    -- Validate WireTotalAmount
    IF @WireTotalAmount IS NULL OR @WireTotalAmount < 0
    BEGIN
        SET @ValidResult = 1
        SET @ErrorCode = '10838' -- Invalid Total Amount
        SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

    IF Abs(ROUND(@ReCalcTotalAmount, 2) - @WireTotalAmount) > 0.01
    BEGIN
        SET @ValidResult = 1
        SET @ErrorCode = '10838' -- Invalid Total Amount
        SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END

    -- Validate AgPayerCode
    IF NOT EXISTS(Select * FROM Wiresearch.dbo.Agencies Where AgencyCode = @AgPayerCode AND AgCountry = @DestCountryDescription AND AgPayer = 1 AND AgPayerStatus in('A','T'))
    BEGIN
        SET @ValidResult = 1
        SET @ErrorCode = '10819' -- The Payer Selected does not pay at the selected Destination Country
        SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        RETURN
    END
END