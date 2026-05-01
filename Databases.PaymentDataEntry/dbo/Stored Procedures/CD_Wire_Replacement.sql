CREATE PROCEDURE [dbo].[CD_Wire_Replacement]
(
	@CurrentLanguageId			INT, 
	@TypeOfChangeOfBeneficiary	INT, -- 1 - Beneficiary Name Mispell, 0 -- New Benefiary
	@Control					INT,
	@UserName					VARCHAR(20),
	@LocationId					INT,
	@ComputerName				VARCHAR(100),
	@StsComplianceOk			BIT,
	@ReceiverId					INT,
	@AgSenderCode				VARCHAR(10),
	@AgComputerId				INT,

	--Signature
	@CertificateThumprint		VARCHAR(100),
	@Signature					VARBINARY(max),

	--New Beneficiary Name
	@NewFirstName				VARCHAR(50),
	@NewLast1					VARCHAR(50),
	@NewLast2					VARCHAR(50),
	@NewPhone					VARCHAR(20) = '',
	
	@ComplianceHitsFound		BIT,
	@1025AgentFullName			VARCHAR(150),
	@Electronic1025				BIT,
	@IdSelected					BIT,

	@EnteredSndDOB				DATETIME,
	@WirePurpose				VARCHAR(200),
	@FundSource					VARCHAR(120),
	@Occupation					VARCHAR(80),
	@SndRcvRelationship			VARCHAR(80),
	@SndEmployerName			VARCHAR(120),		
	@SndEmployerPhone			VARCHAR(20),
	@SenderIdRecId				INT,
	
	--OUTPUT
	@ChangeOfBeneficiaryResult	INT				OUTPUT, --- 0 = ok, 1 = no grabo error no controlado, 500 Error de alguna validacion
	@ErrorCode					VARCHAR(10)		OUTPUT,
	@UserErrorMessage			VARCHAR(300)	OUTPUT,
	@LogErrorMessage			VARCHAR(MAX)	OUTPUT,
	@WireId						INT				OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
	-- AgSender
	@AgSenderId				    INT,
	@AgState					VARCHAR(30),
	@AgCity						VARCHAR(40),
	@AgCountry					VARCHAR(30),
	@TranTypeId					INT,

	-- Sender
	@SenderId					INT,
	@SndVersionId				INT,
	@SenderGroupId				INT,
	@SndFirstName				VARCHAR(50),
	@SndLast1					VARCHAR(50),
	@SndLast2					VARCHAR(50),
	@SndState					VARCHAR(30),
	@SndPhone					VARCHAR(20),
	@SndAddress					VARCHAR(50), 
	@SndCountry					VARCHAR(30),
	@SndCity					VARCHAR(40),
	@Sndzip						VARCHAR(15),
	@SndNoSecLastName			BIT,
	@IsCellPhone				BIT,
	@SndIdType					VARCHAR(5),
	@SndIdNumber				VARCHAR(80),
	@SndIdCountryName			VARCHAR(30),
	@SndIdStateName				VARCHAR(40),
	@SndIdExpirationDate		DATETIME,
	@SameSenderId				INT,
	@OptStatusOpper				CHAR(1), 
	@OptStatusPromo				CHAR(1),

	-- Receiver
	@RcvFirstName				VARCHAR(50), 
	@RcvLast1					VARCHAR(50), 
	@RcvLast2					VARCHAR(50), 
	@RcvAddress					VARCHAR(50),
	@RcvCountry					VARCHAR(30),
	@RcvState					VARCHAR(30),
	@RcvCity					VARCHAR(40),
	@RcvZip						VARCHAR(15),
	@RcvNoSecLastName			BIT,
	@CPF						VARCHAR(11),
	@RcvIdNumber				VARCHAR(80),

	-- WireDepositInfo
	@AccountNumber				VARCHAR(50),
	@DeptBankName				VARCHAR(50),

	-- WireAmountInfo
	@DestAmount					MONEY,
	@DestCurrency				CHAR(3),
	@DestCountry				VARCHAR(50),
	@OriAmount					MONEY,
	@AgencyFee					MONEY,
	@OriCurrency				CHAR(3),
	@RateTypeID					INT,
	@DestCity					VARCHAR(30),
	@DestState					VARCHAR(30),  
	@WireTotalAmount			MONEY,
	@OriCountry					VARCHAR(50),
	@OriState					VARCHAR(50),
	@OriCity					VARCHAR(50), 
	@DestCountryAbbr			CHAR(3),
	@DeliveryType				CHAR(1),
	@SenderPaymentMethodId		INT,
	@FeePlanID					INT,
	@AgCommiPlanID				INT,
	@FxPlanID					INT,
	@FXDif						MONEY,
	@FXShareId					INT,

	@AgPayerId					INT,
	@AgPayerCode				CHAR(10),
	@BranchId					INT,

	@PayerBranchPaymentLimit	MONEY,
	@PayerBranchCurrencyKnowAs	VARCHAR(20),
	@PayerBranchCurrencyCode	CHAR(3),
	@SourceApp					INT,
	@OriToDestExRate			MONEY,
	@AccountType				SMALLINT,
	@DeptAdditionalInfo			VARCHAR(60),
	@BankBranchCode				VARCHAR(7),
	@AgPayerRcvIdTypeRecordId	INT,
	@AcumLoyaltyPoints			BIT,
	@WaivedCharges				MONEY,
	@CashBackAmount				MONEY,
	@Message					VARCHAR(255),
	@ComputerID					VARCHAR(30),

	@LogChangeInfoId			INT = 0,
	@ErrorInt					INT = 0,
	@ReCalcTotalAmount			MONEY,

	@BrState					VARCHAR(30),
	@BrCity						VARCHAR(40),
	@BrName						VARCHAR(40),
	@AgName						VARCHAR(40),
	@BankAccType				SMALLINT,
	@FeeAmount					MONEY,
	@DiscountAmount				MONEY,
	@AgSenderSeq				INT,
		
	@CommissionAmount			MONEY,
	@WireDateTime				DATETIME,
	@RatePlanID					INT,
	@BrPlaceName				VARCHAR(40),
	@WireStateFee				MONEY,
	@BrAddress					VARCHAR(70),
	@AgPhone1					VARCHAR(20),
	@SndDOB						DATETIME,
	@AgencyPricingId			INT,
	@AgencyPricingDetailId		INT,
	@FxBaseId					INT,
	@FXPromotionId				INT,
	@FxBase						money,
	@AgencyFXPointsFromBase		money,
	@AgencyPromoFXPoints		money

	DECLARE @TWire INT, @CanReq INT, @WireStatus INT

	SET @ChangeOfBeneficiaryResult   = 0
	SET @ErrorCode					 = ''
	SET @UserErrorMessage			 = ''
	SET @LogErrorMessage			 = ''
	SET @AgSenderCode				 = LTRIM(RTRIM(@AgSenderCode))
	SET @WireId						 = 0

	BEGIN TRY

	SELECT @TWire = COUNT(*) 
	FROM sqlmain.WireTransac.dbo.WireReplacements T1 
		 JOIN sqlmain.WireTransac.dbo.Wires T2 ON  T1.NewControl = T2.Control
	where ReplacedControl = @Control and T2.StsCancel = 0

	IF @TWire > 0
	BEGIN
		SET @ErrorCode = '10500' -- //'Ya existe un pedido de reemplazo para este Giro.' + 'There is already a replacement Wire request submited for this Wire.'
		SET @ChangeOfBeneficiaryResult = 500
		SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, 1)
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, @CurrentLanguageId) 
		RETURN
	END

	SELECT @CanReq = COUNT(*) 
	FROM sqlmain.WireTransac.dbo.ReqCancellation    
	WHERE Control = @Control AND ReqStatus <> 'C';

	IF @CanReq > 0
	BEGIN
		SET @ErrorCode = '10501' -- //'No puede cambiarse este Giro, porque existe un pedido de cancelacion.' + 'The Wire information cannot be change. There is a cancelation request for active for this Wire.'
		SET @ChangeOfBeneficiaryResult = 500
		SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, 1)
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, @CurrentLanguageId) 
		RETURN
	END

	SELECT @WireStatus = WireStatus
	FROM sqlmain.WireTransac.dbo.Wires WITH(NOLOCK)
	WHERE Control = @Control

	IF @WireStatus = 4
	BEGIN
		SET @ErrorCode = '10661' -- //'El Giro no puede ser cambiado, ya que esta pagado.' + 'This wire is already paid'
		SET @ChangeOfBeneficiaryResult = 500
		SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, 1)
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, @CurrentLanguageId) 
		RETURN
	END

	SELECT 
		@AgSenderId = T1.AgSenderId, 
		@AgState = T9.AgState, 
		@AgCity = T9.AgCity, 
		@AgCountry = T9.AgCountry,
		@SenderId = T1.SenderId,    
		@SndFirstName = T2.SndFirstName, 
		@SndLast1 = T2.SndLast1, 
		@SndLast2 = T2.SndLast2, 		   
		@SndAddress = T2.SndAddress, 
		@SndCity = T2.SndCity, 
		@SndState = T2.SndState, 
		@SndZip = T2.SndZip, 
		@SndPhone = T2.SndPhone, 
		@SndCountry = T2.SndCountry, 
		@SndNoSecLastName = T2.NoSecLastName, 
		@SenderGroupId = T2.SenderGroupId, 
		@SameSenderId = T2.SameSenderId,
		@ReceiverId= T3.Receiverid,
		@RcvAddress = T3.RcvAddress, 
		@RcvCountry = T3.RcvCountry, 
		@RcvNoSecLastName = T3.NoSecLastName,
		@RcvState = RcvState, 
		@RcvCity = RcvCity, 
		@RcvZip = RcvZip, 
		@BrCity = T5.BrCity, 
		@BrState = T5.BrState, 
		@BrName = T5.BrName, 
		@AgName = T6.AgName,
		@AgPayerId = T6.AgencyId,		   
		@DeptBankName = DeptBankName, 
		@AccountNumber = AccountNumber, 
		@DeptAdditionalInfo = DeptAdditionalInfo,
		@BankBranchCode = BankBranchCode, 
		@BankAccType = BankAccType,
		@OriAmount = OriAmount, 
		@FeeAmount = T1.Charges,
		@WaivedCharges = T1.Charges + T1.OtherChg,
		@AgencyFee = AgencyFee, 
		@WireTotalAmount = WireTotalAmount, 	   
		@OriToDestExRate = OriToDestExRate, 
		@DestAmount = DestAmount, 
		@DiscountAmount = DiscountAmount,
		@AgSenderSeq = T1.AgSenderSeq, 
		@WireDateTime = WireDateTime, 
		@DestCurrency = DestCurrency,
		@OriCurrency = OriCurrency,
		@CPF	= T3.CPF, 
		@TranTypeID = T1.TranTypeID, 
		@AgPayerCode = AgPayerCode, 
		@BranchId = T1.BranchId, 
		@BrPlaceName = T5.BrPlaceName, 
		@BrAddress = T5.BrAddress, 
		@DeliveryType = T1.DeliveryType, 
		@Message = T11.Message,
		@AgName = T9.AgName, 
		@AgPhone1 = T9.AgPhone1, 
		@SndDOB = T10.SndDOB, 
		@DestState  = T1.DestState,
		@DestCity  = T1.DestCity,
		@DestCountry = T1.DestCountry, 
		@CashBackAmount = T1.CashBackAmount, 
		@SenderPaymentMethodId = 1,
		@SourceApp = T1.SourceApp,
		@RateTypeID = T1.RateTypeID,
		@ComputerID = T1.ComputerID,
		@FeePlanID = T8.FeePlanID,
		@AgCommiPlanID = T8.AgCommiPlanID,
		@FxPlanID = T8.ExRatePlanID,
		@FXDif = T8.FXDif,
		@FXShareId = T8.FxShareId,

		@AgencyPricingId	= T8.AgencyPricingId,
		@AgencyPricingDetailId	= T8.AgencyPricingDetailId,
		@FxBaseId	= T8.FxBaseId,
		@FXPromotionId	= T8.FXPromotionId,
		@FxBase	= T8.FxBase,
		@AgencyFXPointsFromBase	= T8.AgencyFXPointsFromBase,
		@AgencyPromoFXPoints	= T8.AgencyPromoFXPoints

	FROM sqlmain.WireTransac.dbo.Wires T1
		join sqlmain.WireTransac.dbo.SenderVersions T2 ON T1.SenderID = T2.Senderid and T2.SndVersionId = T1.SndVersionId
		join sqlmain.WireTransac.dbo.ReceiverVersions T3 ON T1.ReceiverID = T3.Receiverid and T3.RcvVersionId = T1.RcvVersionId
		join sqlmain.WireTransac.dbo.TransactionTypes T4 ON T1.TranTypeID = T4.TranTypeID
		left outer join sqlmain.WireTransac.dbo.Branches T5 ON T1.Branchid = T5.BranchID
		left outer join sqlmain.WireTransac.dbo.Agencies T6 ON T5.AgencyID = T6.AgencyID
		left outer join sqlmain.WireTransac.dbo.ViewDeliveryTypes T7 ON T7.DeliveryType = T1.DeliveryType
		left outer join WirePricing.dbo.Prc_WirePlans T8 ON T8.Control = T1.Control
		left outer join sqlmain.WireTransac.dbo.Agencies T9 ON T9.AgencyId = T1.AgSenderId
		left outer join sqlmain.WireTransac.dbo.WireCompInfo T10 ON T10.Control = T1.Control
		left outer join sqlmain.WireTransac.dbo.WireMessages T11 ON T11.Control = T1.Control
		left outer join sqlmain.WireTransac.dbo.AgSenders T12 ON T12.AgencyId = T1.AgSenderId 
	WHERE T1.Control = @Control 

	IF @@Rowcount = 0
	BEGIN
		SET @ErrorCode = '11283' -- Could not find the preparation record
		SET @ChangeOfBeneficiaryResult = 500
		SET @LogErrorMessage  = 'No record on wire - ' + ' Agency ' + @AgSenderCode
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) --The wire could not be saved, please close the transaciont window and try again
		RETURN
	END

	SELECT @SndFirstName = [dbo].[CleanWhiteSpaces](@SndFirstName)
	SELECT @SndLast1 = [dbo].[CleanWhiteSpaces](@SndLast1)
	SELECT @SndLast2 = [dbo].[CleanWhiteSpaces](@SndLast2)

	SELECT @RcvFirstName = [dbo].[CleanWhiteSpaces](@NewFirstName)
	SELECT @RcvLast1 = [dbo].[CleanWhiteSpaces](@NewLast1)
	SELECT @RcvLast2 = [dbo].[CleanWhiteSpaces](@NewLast2)

	DECLARE @SndFullName varchar(150)
	DECLARE @RcvFullName varchar(150)
	DECLARE @PayerPayMethodId int = 1 --CASH
	DECLARE @CLRResult bit
	DECLARE @SignedData varchar(max)
	DECLARE @PublicKey varchar(max)

	SET @SndFullName =rtrim(@SndFirstName+' '+@SndLast1+' '+@SndLast2)
	SET @RcvFullName =rtrim(@RcvFirstName+' '+@RcvLast1+' '+@RcvLast2)
	SET @SignedData = @AgSenderCode + '|' + @SndFullName  + '|' +  @RcvFullName + '|' +  @AccountNumber + '|' +  @DestCurrency  + '|' +  Cast(@DestAmount as varchar)

	SELECT @PublicKey=PublicKey
	FROM ImxDirectSecurity.dbo.ImxDirect_AgencyComputerCertificates
	WHERE Thumbprint = @CertificateThumprint

	EXEC @CLRResult = SqlCLR.dbo.ImxDirect_VerifySignature @PublicKey,@SignedData,@Signature

	IF (@CLRResult = 0)
	BEGIN
		SET @ErrorCode        = '11269' -- Signature Not Valid
		SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
		INSERT INTO dbo.ImxDirect_SignedDataErrorLog (AgSenderCode,DT,SignedData ,Signature)
											VALUES (@AgSenderCode,getdate(),@SignedData ,@Signature)
		RETURN
	END

	-- Validate Payer Limit
	DECLARE @PayerLimit TABLE(CurrencyCode varchar(3),
							PaymentLimit money,
							CurrencyKnownAs varchar(20))
	
	INSERT INTO @PayerLimit(CurrencyCode,
							PaymentLimit,
							CurrencyKnownAs)
	EXEC Wiresearch.dbo.GetPayerPaymentLimit @AgPayerId, @TranTypeiD, @OriCurrency, @DestCurrency

	IF EXISTS(SELECT 1 FROM @PayerLimit WHERE (CurrencyCode = @OriCurrency AND @OriAmount > PaymentLimit) OR (CurrencyCode = @DestCurrency AND @DestAmount > PaymentLimit))
	BEGIN
		SET @ErrorCode = '10452' -- The max amount allowed to send by this payer is {0} {1}. Change Beneficiary cannot be done.
		SET @ChangeOfBeneficiaryResult = 500
		SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)

		SELECT TOP 1 @PayerBranchPaymentLimit = PaymentLimit, 
						@PayerBranchCurrencyKnowAs = CurrencyKnownAs
		FROM @PayerLimit

		SET @LogErrorMessage = REPLACE(REPLACE(@LogErrorMessage, '{0}', CAST(@PayerBranchPaymentLimit AS VARCHAR)),'{1}',@PayerBranchCurrencyKnowAs)
		SET @UserErrorMessage = REPLACE(REPLACE(@UserErrorMessage, '{0}', CAST(@PayerBranchPaymentLimit AS VARCHAR)),'{1}',@PayerBranchCurrencyKnowAs)

		RETURN
	END
	-- End Validate Payer Limit

	-- Validate Branch Limit
	IF @TranTypeID = 1
	BEGIN
		SELECT @PayerBranchCurrencyCode = T1.CurrencyCode, 
				@PayerBranchPaymentLimit = PaymentLimit, 
				@PayerBranchCurrencyKnowAs = T2.CurrencyKnownAs
		FROM SqlMain.WireTransac.dbo.BranchPaymentLimit T1
		JOIN SqlMain.WireTransac.dbo.Currencies T2 ON T2.CurrencyCode = T1.CurrencyCode
		WHERE BranchId = @BranchId

		IF (@PayerBranchCurrencyCode = @OriCurrency AND @OriAmount > @PayerBranchPaymentLimit) OR (@PayerBranchCurrencyCode = @DestCurrency AND @DestAmount > @PayerBranchPaymentLimit)
		BEGIN
			SET @ErrorCode = '10451' -- The max amount allowed to send by this payer is {0} {1}. Change Beneficiary cannot be done.
			SET @ChangeOfBeneficiaryResult = 500
			SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
			SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)

			SET @LogErrorMessage = REPLACE(REPLACE(@LogErrorMessage, '{0}', CAST(@PayerBranchPaymentLimit AS VARCHAR)),'{1}',@PayerBranchCurrencyKnowAs)
			SET @UserErrorMessage = REPLACE(REPLACE(@UserErrorMessage, '{0}', CAST(@PayerBranchPaymentLimit AS VARCHAR)),'{1}',@PayerBranchCurrencyKnowAs)

			RETURN
		END
	END
	-- End Validate Branch Limit

	-- Validate the payer is Active
	IF NOT EXISTS (SELECT AgencyId from WireSearch.dbo.Agencies where AgencyId = @AgPayerId and AgPayerStatus in ('A', 'T'))
	BEGIN
		SET @ErrorCode = '10661' -- //'El pagador ya No se encuentra Activo, Por favor cancele este giro y haga el nuevo por otro pagador.' + 'The payer is not longer Active, Please Cancel this wire and do a new one with another payer.'
		SET @ChangeOfBeneficiaryResult = 500
		SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, 1)
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, @CurrentLanguageId) 
		RETURN
	END

	IF EXISTS (Select AgencyCode FROM WireSearch.dbo.Agencies Where AgencyCode = @AgSenderCode and WebAgent = 1)
    BEGIN
		SET @ErrorCode = '10653' -- Agencia Invalida - Invalid Agency
		SET @ChangeOfBeneficiaryResult = 500
		SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, 1)+' Agency '+ @AgSenderCode
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, @CurrentLanguageId)
		RETURN
    END

	IF @AgPayerCode is null or RTRIM(ltrim(@AgPayerCode)) = ''
    BEGIN
		SET @ErrorCode = '11179' -- El pagador no puede estar en blanco - Payer cannot be blank
		SET @ChangeOfBeneficiaryResult = 500
		SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, 1)
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, @CurrentLanguageId) 
		RETURN
    END

	IF @AgPayerCode IN ('CL-06', 'CL-09', 'CL-10', 'CL-017', 'CL-018') OR UPPER(@DestCountry) = 'HONDURAS'
	BEGIN
		EXEC WirePricing.dbo.Prc_WireGetCharges_FXRedesign_V2 
			@pI_AgSenderCode = @AgSenderCode,
			@pI_AgPayerCode = @AgPayerCode,
			@pI_WireAmount= @OriAmount,
			@pI_OriCurrency = @OriCurrency,
			@pI_DeliveryType = @DeliveryType,
			@pI_TranTypeID = @TranTypeID, 
			@pI_DestCountry = @DestCountry,
			@pI_DestCurrency = @DestCurrency,
			@pI_RateTypeID = @RateTypeID,

			@pO_FeeAmount = @FeeAmount OUTPUT,
			@pO_CommissionAmount = @CommissionAmount OUTPUT,
			@pO_OriToDestExRate	= @OriToDestExRate OUTPUT,
			@pO_DestAmount = @DestAmount OUTPUT,
			@pO_FeePlanID = @FeePlanID OUTPUT,
			@pO_CommPlanID	= @AgCommiPlanID OUTPUT,
			@pO_RatePlanID = @RatePlanID OUTPUT,
			@pO_FXDif = @FXDif OUTPUT,
			@pO_FXShareId = @FXShareId OUTPUT,
			@pO_WireStateFee = @WireStateFee OUTPUT
	END

	IF @OriToDestExRate is null or @OriToDestExRate <= 0
    BEGIN
		SET @ErrorCode = '10227' -- Invalid Exchange Rate, Please check if that Payer is setup properly
		SET @ChangeOfBeneficiaryResult = 500
		SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) 
		RETURN 
    END
	
	IF @DestCurrency = @OriCurrency AND @OriToDestExRate <> 1
	BEGIN
		SET @ErrorCode = '10227' -- Invalid Exchange Rate, Please check if that Payer is setup properly
		SET @ChangeOfBeneficiaryResult = 500
		SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) 
		RETURN
    END

	SET @WireTotalAmount = ISNULL(@OriAmount, 0) + ISNULL(@AgencyFee, 0) + ISNULL(@CashBackAmount, 0)
	SET @RateTypeID = CASE WHEN @RateTypeID = 0 THEN 1 ELSE @RateTypeID END

	IF (@SenderId = 0 or @SenderId is null) AND @SenderGroupId > 0 
		SET @SenderGroupId = 0

	EXEC [dbo].[spi_CreateWireTransfer_DataEntry]
		--Senders
		@SenderId = @SenderId,
		@SenderGroupId = @SenderGroupId,
		@SndFullName = @SndFullName,
		@SndFirstName = @SndFirstName,
		@SndLast1 = @SndLast1,
		@SndLast2 = @SndLast2,
		@SndAddress = @SndAddress,
		@SndCountry = @SndCountry,
		@SndState = @SndState,
		@SndCity = @SndCity,
		@SndZip = @SndZip,
		@SndPhone = @SndPhone,
		@SndLastVersionId = 0,
		@SndNoSecLastName = @SndNoSecLastName,

		--Receivers
		@ReceiverId = @ReceiverId,
		@ReceiverGroupId = 0,
		@RcvFullName = @RcvFullName,
		@RcvFirstName = @RcvFirstName,
		@RcvLast1 = @RcvLast1,
		@RcvLast2 = @RcvLast2,
		@RcvAddress = @RcvAddress,
		@RcvCountry = @RcvCountry,
		@RcvState = @RcvState,
		@RcvCity = @RcvCity,
		@RcvZip = @RcvZip,
		@RcvPhone = @NewPhone,
		@RcvNoSecLastName = @RcvNoSecLastName,
		@RcvLastVersionID = 0,
		@CPF = @CPF,
	
		--Wire info
		@AgSenderId = @AgSenderId,
		@AgSenderCode = @AgSenderCode,
		@AgSenderState = @AgState,
		@AgSenderCity =	@AgCity,
		@AgSenderCountry = @AgCountry,
	
		@AgPayerId = @AgPayerId,
		@AgPayerCode = @AgPayerCode,
		@DestCountry = @DestCountry,
		@DestState = @DestState,
		@DestCity = @DestCity,
		@BranchId = @BranchId,
	
		@OnBehalfId = NULL, --Sender OnBehalf

		@OriAmount = @OriAmount,
		@OriCurrency = @OriCurrency,
		@Charges = 0,
		@OtherChg = 0,
		@AgencyFee = 0,
		@OriToDestExRate = @OriToDestExRate,
		@WireStateFee = 0,
		@WireTotalAmount = @WireTotalAmount,
		@DestAmount = @DestAmount,
		@DestCurrency = @DestCurrency,
		@AgSenderCommission = 0,
		@TranTypeID = @TranTypeID,
		@PinNumber = NULL, 
		@Message = @Message,
	
		@AgCompID = @AgComputerId,
		@ComputerId = @ComputerId,
		@AppVersion = '3.23.104.646 CD',
    
		--Deposit
		@AccountNumber = @AccountNumber,
		@DeptBankName = @DeptBankName,
		@AccountType = @AccountType,
		@DeptAdditionalInfo = @DeptAdditionalInfo,
		@BankBranchCode = @BankBranchCode,
	
		@DeliveryType = @DeliveryType,
		@SourceApp = @SourceApp,
		@StsCancel = 0,
		@CustTrasactionID = 0,
		@RateTypeID = @RateTypeID,
		@FeePlanID = @FeePlanID,
		@FxPlanID = @FxPlanID,
		@AgCommiPlanID = @AgCommiPlanID,
		@FXDif = @FXDif,
		@FXShare_id = @FXShareId,
		@ExRateMacro = @RateTypeID,
		@WirePurpose = @WirePurpose,
		@FundSource = @FundSource,
		@Occupation = @Occupation,
		@IncomingPhoneNumber = '',
		@CallerIDVerif = 0,
		@TeledirectWire = 0,
		@NoFaxBackWire = 0,
		@ReplacedControl = @Control,
		@WaivedCharges = @WaivedCharges,
		@ReplaceWireRcvSel = 1,
		@WireReplacementType = 2,
		@ReplacementReasonID = 0,
		@MemberCardSwiped = 0,
		@EnteredSndDOB = @EnteredSndDOB,    
		@Elect1025_IDOk  = 0,
		@CreatedBy = @UserName,
		@ComputerName = @ComputerName

	SELECT @WireId = WireId FROM PaymentDataEntry.dbo.Wires WHERE ReplacedControl = @Control

	-- Create Request of Cancellation for Original Wire
	EXEC sqlmain.wiretransac.[dbo].[ReqCancellation_Create] @Control, 32, 1, @UserName, @LocationId, @LogChangeInfoId, @ErrorInt 
	IF @ErrorInt > 0
	BEGIN
		SET @LogErrorMessage = CAST(@ErrorInt as VARCHAR(10)) + '. Error creating Request of Cancellation '
		;THROW 55000, @LogErrorMessage, 1
	END

	-- Update Original Wire WireReplacementType = 1
	EXEC sqlmain.wiretransac.[dbo].Wires_UpdateAsReplacement @Control, @LogChangeInfoId

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;

		SET @ChangeOfBeneficiaryResult = 1
		SET @ErrorCode = '11283' -- An Unexpected error has occurred, please try again and if the error persists contact technical support
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, @CurrentLanguageId)
		SET @LogErrorMessage  =  'CD_Wire_Replacement - ' + ERROR_MESSAGE()
	END CATCH
END