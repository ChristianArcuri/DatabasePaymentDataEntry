CREATE PROCEDURE [dbo].[ImxDirect_WIRE_CreateAWireTransfer_V4]
(
    @PreparationId UNIQUEIDENTIFIER,
	@CurrentLanguageId INT,
	--Senders
	@SenderId INT,
	@SenderGroupId INT,
	@SndFirstName VARCHAR(50),
	@SndLast1 VARCHAR(50),
	@SndLast2 VARCHAR(50) ,
	@SndAddress VARCHAR(50),
	@SndCountry VARCHAR(30),
	@SndState VARCHAR(30),
	@SndCity VARCHAR(40),
	@SndZip VARCHAR(15),
	@SndPhone VARCHAR(20),
	@SndLastVersionId INT,
	@SndNoSecLastName BIT,
	@IsCellPhone BIT,
	-- Fields add for AgPayerIdRequirements -- ( Payers that required Id over certain amount )
    @SndIdType VARCHAR(5),
    @SndIdNumber VARCHAR(80),
    @SndIdCountryName VARCHAR(30),
    @SndIdStateName VARCHAR(40),
    @SndIdExpirationDate DATETIME,
	--CRM
	@SameSenderId INT , -- New x Loyalty
	@AcumLoyaltyPoints BIT, --New x Loyalty
	@PointsToRedeem INT, --New x Loyalty
	@PointsRedemptionId INT, --New x Loyalty
    @OptStatusOpper CHAR(1),
	@OptStatusPromo CHAR(1),
	@MemberCardSwiped BIT,
	@LoyaltyCardNumber VARCHAR(50),
   

    --Receivers
	@ReceiverId INT,
	@ReceiverGroupId INT,
	@RcvFirstName VARCHAR(50),
	@RcvLast1 VARCHAR(50),
	@RcvLast2 VARCHAR(50),
	@RcvAddress VARCHAR(200),
	@RcvCountry VARCHAR(30),
	@RcvState VARCHAR(30),
	@RcvCity VARCHAR(40),
	@RcvZip VARCHAR(15),
	@RcvPhone VARCHAR(20),
	@RcvNoSecLastName BIT,
	@RcvLastVersionID INT,
	@CPF VARCHAR(11),
	@RcvDOB DATETIME,
	@MessageToRcv VARCHAR(255),

	--Wire info
	@AgSenderId INT,
	@AgSenderCode VARCHAR(10),
	@AgSenderState VARCHAR(30),
	@AgSenderCity VARCHAR(40),
	@AgSenderCountry VARCHAR(30),

	@AgPayerId INT,
	@AgPayerCode VARCHAR(10),
	@DestCountry VARCHAR(30),
	@DestState VARCHAR(30),
	@DestCity VARCHAR(40),
	@BranchId INT,
	@PayerPromoId INT, --New

	--Transaction
	@TranTypeID INT,
	@DeliveryType CHAR(1),
	@SourceApp INT,
	--Amounts
	@AgPlanAssignId INT, --new
	@OriAmount MONEY,
	@OriCurrency CHAR(3),
	@Charges MONEY,
	@OtherChg MONEY,
	@AgencyFee MONEY,
	@OriToDestExRate MONEY,
	@WireStateFee MONEY,
	@WireTotalAmount MONEY,
	@DestAmount MONEY,
	@DestCurrency CHAR(3),
	@AgSenderCommission MONEY,
	@DiscountAmount MONEY, 

		

	
	--Deposit
	@AccountNumber VARCHAR(30),
	@DeptBankName VARCHAR(60),
	@AccountType SMALLINT,
	@DeptAdditionalInfo VARCHAR(60),
	@BankBranchCode VARCHAR(7),
	@AgPayerRcvIdTypeRecordId INT, 
	@RcvIdNumber VARCHAR(80),

	
	--CFPB
	@UserAcceptCFPB VARCHAR(50),  --New (crearlo en wires y pasarlo x el bridge)

	--Compliance
	@EnteredSndDOB DATETIME,
	@WirePurpose VARCHAR(200),
	@FundSource VARCHAR(120),
	@Occupation VARCHAR(80),
	@SndRcvRelationship VARCHAR(80),
	@SndEmployerName VARCHAR(120),
	@SndEmployerPhone VARCHAR(20),
	@SenderIdRecId INT,
	@Compliance_GUID UNIQUEIDENTIFIER,
	@StsComplianceOk BIT,
	@ComplianceHitsFound BIT,
	@Electronic1025 BIT, --Nuevo version 4!!!!!!!!!!!!!!!!!!!!!!!
	@1025AgentFullName VARCHAR(150),--1025 without sign


	--WireReplacement
	@ReplacedControl INT,
	@WaivedCharges MONEY,
	@ReplaceWireRcvSel INT,
	@WireReplacementType INT,
	@ReplacementReasonID INT,


	--Card Direct
	@CardChargeId INT,
	@SenderPaymentMethodId INT,
	@WireSenderPaymentMethodFee MONEY,
	@CashBackAmount MONEY,
	@CardDirectProviderId INT,


	--Security
	@AgComputerId INT          ,
	@FingerPrint  VARCHAR(200),
	@ComputerName VARCHAR(100),
	@AgUserId     INT          ,
    @AppVersion VARCHAR(50),
   --@Token varchar(200),
   --@WireTAG varchar(15),
   --@AppHash varbinary(32),
   --@PswHash  varbinary(32),
    @ClientIP VARCHAR(50),

	--Signature
	@CertificateThumprint VARCHAR(100),
	@Signature VARBINARY(MAX),
	@Nationality VARCHAR(50),

	--OUTPUT
    @WireId INT OUTPUT,
    @AgSenderSeq INT OUTPUT,
	@PinNumber VARCHAR(20) OUTPUT, 
    @WireDatetime DATETIME OUTPUT,
    @WireAvailableDate DATETIME OUTPUT,
	@WireResult INT OUTPUT, --- 0 = ok, 1 = no grabo error no controlado, 500 Error de alguna validacion
    @ErrorCode VARCHAR(10) OUTPUT,
    @UserErrorMessage VARCHAR(300) OUTPUT,
    @LogErrorMessage VARCHAR(MAX) OUTPUT
)     
AS  
  Set nocount on;

  DECLARE @LSenderID int, @LReceiverID int
  DECLARE @InsSender bit, @InsReceiver bit, @DoItNow bit
  DECLARE @WireDate datetime, @CheckSender bit
  DECLARE @D DATETIME, @DateOnly DATETIME
  DECLARE @Result int, @Delay int
  DECLARE @IP varchar(100), @InsertPossibleFraud bit = 0
  DECLARE @PointsAdded int
  DECLARE @PointsTranType varchar(10)  
  DECLARE @WirePoints int, @WirePointsSign int
  DECLARE @ReCalcTotalAmount money
  DECLARE @AgencyExtraFee money = 0
  DECLARE @CreatedBy varchar(20)
  DECLARE @WireInfoForLog varchar(max)
  DECLARE @SndIdTypeName varchar(50) = ''
  DECLARE @SndFullName varchar(150)
  DECLARE @RcvFullName varchar(150)
  DECLARE @PayerPayMethodId int = 1 --CASH
  DECLARE @CLRResult bit
  DECLARE @SignedData varchar(max)
  DECLARE @PublicKey varchar(max)
  DECLARE @TestAgency bit = 0


 DECLARE @FXPointsAdded money,
		@FXChangeCost money,
		@FXCostApplyTo char(1),
		@RateTypeID int,
		@FeePlanID int,
		@FxPlanID int,
		@AgCommiPlanID int,
		@FXDif money,
		@FXShare_id int,
		@FeeChange money,
		@CostToAgent money,
		@CostToCustomer money,
		@FlexPrcOptionSelected char(1),
		@PromoCostToCompany MONEY, 
		@PromoCostToAgent MONEY, 
		@PromoCostToPayer MONEY, 
		@CRMPromotionId INT, 
		@SenderPromoUniqueKey VARCHAR(50),
		@WiresAlreadyCountGUID uniqueidentifier,
		@AgencyPricingId INT,
		@AgencyPricingDetailId INT, 
		@FxBaseId INT,
		@FXPromotionId INT, 
		@FxBase MONEY, 
		@AgencyFXPointsFromBase MONEY,
		@AgencyPromoFXPoints MONEY


  SET @WireResult = 0
  SET @WireId = 0
  SET @AgSenderSeq  = 0
  SET @PinNumber =''
  SET @ErrorCode =''
  SET @UserErrorMessage =''
  SET @LogErrorMessage =''


   ----==========================================================================GERU==========================================================
  insert into ImxDirect_PerformanceLog(Sp,PreparationId ,AgSenderCode ,Step ,StepTime )
                               values ('ImxDirect_WIRE_CreateAWireTransfer_V4',@PreparationId,@AgSenderCode,1,getdate())
----===========================================================================================================================================

   ----VALIDAR QUE NO VENGA NINGUN DATO EN NULL!!!!!!!!!!!!!!!!!
  

  IF @SenderId IS NULL
     SET @SenderId= 0
  IF @SenderGroupId IS NULL
     SET @SenderGroupId = 0

  IF @SndNoSecLastName IS NULL
     SET @SndNoSecLastName = 0
  IF @IsCellPhone IS NULL
     SET @IsCellPhone = 0

	IF @SndIdType IS NULL
	   SET @SndIdType = ''
	IF @SndIdNumber IS NULL
	   SET @SndIdNumber = ''
	IF @SndIdCountryName IS NULL
	   SET @SndIdCountryName = ''
	IF @SndIdStateName IS NULL
	   SET @SndIdStateName = ''
	IF @SameSenderId IS NULL
	   SET @SameSenderId = 0
	IF @AcumLoyaltyPoints IS NULL
	   SET @AcumLoyaltyPoints  =0
	IF @PointsToRedeem IS NULL
	   SET @PointsToRedeem = 0
	IF @PointsRedemptionId IS NULL
	   SET @PointsRedemptionId = 0

	IF @OptStatusOpper IS NULL
	   SET @OptStatusOpper = ''
	IF @OptStatusPromo IS NULL
	   SET @OptStatusPromo = ''

	IF @RcvNoSecLastName IS NULL
	   SET @RcvNoSecLastName = ''

    if @CPF is NULL
	   SET @CPF = ''

	SET @SndPhone = dbo.justnum(@SndPhone)

	IF @AgPayerId IS NULL
	OR @AgPayerId = 0
	OR @AgPayerCode IS NULL 
	OR @AgPayerCode = ''
	   BEGIN
		   SET @ErrorCode = '11179' -- Payer cannot be blank
		   SET @WireResult      = 500
		   SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
		   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
		   RETURN
	   END

   IF @DestCountry IS NULL
      SET @DestCountry = ''
   IF @DestState IS NULL
      SET @DestState = ''
   IF @DestCity IS NULL
      SET @DestCity = ''

   IF @BranchId is null
      SET @BranchId = 0


   IF @TranTypeID IS NULL
      SET @TranTypeID = 0
   IF @DeliveryType IS NULL
      SET @DeliveryType = ''

   IF @AccountNumber IS NULL
      SET @AccountNumber = ''
   
   IF @DeptBankName IS NULL
      SET @DeptBankName  = ''

   IF @AccountType IS NULL
      SET @AccountType = 0

   IF @DeptAdditionalInfo IS NULL
	   SET @DeptAdditionalInfo = ''
   IF @BankBranchCode IS NULL
      SET @BankBranchCode = ''
 
   IF @PayerPromoId IS NULL
      SET @PayerPromoId = 0

--Amounts
  IF @AgPlanAssignId IS NULL
     SET @AgPlanAssignId = 0

  IF @OriAmount IS NULL
     SET @OriAmount = 0
  IF @OriCurrency IS NULL
     SET @OriCurrency = ''
  IF @Charges IS NULL
     SET @Charges = 0
  IF @OtherChg IS NULL
     SET @OtherChg = 0
  IF @AgencyFee IS NULL
     SET @AgencyFee = 0
  IF @OriToDestExRate IS NULL
     SET @OriToDestExRate = 0
  IF @WireStateFee IS NULL
     SET @WireStateFee = 0
  IF @WireTotalAmount IS NULL
     SET @WireTotalAmount = 0
	 
  IF @DestAmount IS NULL
     SET @DestAmount = 0
  IF @DestCurrency IS NULL
     SET @DestCurrency = ''
  IF @AgSenderCommission IS NULL
     SET @AgSenderCommission = 0
  IF @DiscountAmount IS NULL
     SET @DiscountAmount = 0


  --Card Direct
  IF @CardChargeId IS NULL
     SET @CardChargeId = 0
  IF @SenderPaymentMethodId IS NULL
     SET @SenderPaymentMethodId =0
  IF @WireSenderPaymentMethodFee IS NULL
     SET @WireSenderPaymentMethodFee =0
  IF @CashBackAmount IS NULL
     SET @CashBackAmount = ''
  IF @CardDirectProviderId IS NULL
     SET @CardDirectProviderId =0 
	
  IF @ComputerName IS NULL
     SET @ComputerName = '' 
  IF @ClientIP IS NULL
     SET @ClientIP = ''
----FIN =================================VALIDAR QUE NO VENGA NINGUN DATO EN NULL!!!!!!!!!!!!!!!!!



	IF @AgSenderCode = 'CA-4618'
	   BEGIN
	     SET @ErrorCode = '11305' -- Could not find the preparation record
	     SET @WireResult       = 500
	     SET @LogErrorMessage  = 'Error de conexion intentando procesar la transaccion / Internal connection error attempting to process transaction'
	     SET @UserErrorMessage = 'Error de conexion intentando procesar la transaccion / Internal connection error attempting to process transaction'
	     RETURN
	   END


BEGIN TRY 

  ----------------------
   -- PROMO , REDEEEM, PAYERPROMO, FLEX_FX, FLEX_FEE, MULTIPLEOF
  SET @RateTypeID = 1

  DECLARE @FlexPriceValueApplied decimal(10,4),
          @FlexPriceCost money,
          @PromoFxDif decimal(10,4),
          @PromoFxCost money,
          @PriceAffectedBy varchar(10)


  SELECT @PriceAffectedBy       = PriceAffectedBy,
         @FlexPriceValueApplied = FlexPriceValueApplied,
		 @FlexPriceCost         = FlexPriceCost,
		 @PromoFxDif            = PromoFxDif,
		 @PromoFxCost           = PromoFxCost,
	     @FXCostApplyTo         = CASE WHEN PriceAffectedBy like 'FLEX%' then FlexPriceCostApplyTo else '' end,
		 @FlexPrcOptionSelected = CASE WHEN PriceAffectedBy = 'FLEX_FX' then 'F' else  CASE WHEN PriceAffectedBy = 'FLEX_FEE' then 'C' else '' end end,
		 @FeePlanID             = FeePlanID,
		 @FxPlanID              = ExRatePlanID,
	     @AgCommiPlanID         = CommPlanID,
	     @FXDif                 = FXDif,
		 @FXShare_id            = FXShareId,
	     @FeeChange             = CASE WHEN PlanFeeAmount <> WireFeeAmount then (WireFeeAmount-PlanFeeAmount) else 0 end,
	     @CostToAgent           = CASE WHEN PriceAffectedBy like 'FLEX%' and FlexPriceCostApplyTo <> 'C' and PlanCommissionAmount <> WireCommissionAmount then (WireCommissionAmount-PlanCommissionAmount) else 0 end,
	     @CostToCustomer        = CASE WHEN PriceAffectedBy like 'FLEX%' and FlexPriceCostApplyTo <> 'A' and PlanFeeAmount <> WireFeeAmount  then (WireFeeAmount-PlanFeeAmount) else 0 end,
	     @PromoCostToCompany    = PromoCostToCompany,
	     @PromoCostToAgent      = PromoCostToAgent, 
	     @PromoCostToPayer      = PromoCostToPayer, 
	     @CRMPromotionId        = PromotionId, 
	    -- @SenderPromoUniqueKey  = '',
		 @SenderPromoUniqueKey  = CASE WHEN EXISTS(SELECT 1 FROM WirePricing.dbo.crm_promotions WHERE promotionid = PromotionId and generateuniquekey =1) THEN PromoCode ELSE '' END,
		 @WiresAlreadyCountGUID = WiresAlreadyCountGUID,
		 @StsComplianceOk       = StsComplianceOk,
		 @AgencyPricingId		= AgencyPricingId,
		 @AgencyPricingDetailId = AgencyPricingDetailId,
		 @FxBaseId				= FxBaseId,
		 @FXPromotionId			= FXPromotionId,
		 @FxBase				= FxBase,
		 @AgencyFXPointsFromBase= AgencyFXPointsFromBase,
		 @AgencyPromoFXPoints	= AgencyPromoFXPoints
    FROM ImxDirect_WireInPreparation
   WHERE PreparationId = @PreparationId
     AND AgSenderCode  = @AgSenderCode
	 AND OriAmount             = @OriAmount
	 and OriCurrencyCode       = @OriCurrency
	 AND SenderPaymentMethodId = @SenderPaymentMethodId
	 AND TranTypeId            = @TranTypeId
	 AND AgPayerCode           = @AgPayerCode
	 AND DestCurrencyCode      = @DestCurrency
	 And DeliveryType          = @DeliveryType
	 AND AgPlanAssignId        = @AgPlanAssignId 
	IF @@Rowcount = 0
	   BEGIN
	     SET @ErrorCode = '11305' -- Could not find the preparation record
	     SET @WireResult       = 500
	     SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)+' Agency '+@AgSenderCode
	     SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage ('11306',@CurrentLanguageId) --The wire could not be saved, please close the transaciont window and try again
	     RETURN
	   END

  -----
  SET @FXPointsAdded         = 0
  SET @FXChangeCost          = 0
  IF @PriceAffectedBy = 'FLEX_FX'
     BEGIN
       SET @FXPointsAdded         = @FlexPriceValueApplied 
	   SET @FXChangeCost          = @FlexPriceCost 
	 END
   IF @PriceAffectedBy = 'REDEEM'
     BEGIN
	   SET @FXPointsAdded         = @PromoFxDif 
	   SET @FXChangeCost          = @PromoFxCost 
	 END

  SELECT @SndFirstName = [dbo].[CleanWhiteSpaces](@SndFirstName)
  SELECT @SndLast1 = [dbo].[CleanWhiteSpaces](@SndLast1)
  SELECT @SndLast2 = [dbo].[CleanWhiteSpaces](@SndLast2)

  SELECT @RcvFirstName = [dbo].[CleanWhiteSpaces](@RcvFirstName)
  SELECT @RcvLast1 = [dbo].[CleanWhiteSpaces](@RcvLast1)
  SELECT @RcvLast2 = [dbo].[CleanWhiteSpaces](@RcvLast2)

  SET @SndFullName =rtrim(@SndFirstName+' '+@SndLast1+' '+@SndLast2)
  SET @RcvFullName =rtrim(@RcvFirstName+' '+@RcvLast1+' '+@RcvLast2)
  SET @SignedData = @AgSenderCode + '|' + @SndFullName  + '|' +  @RcvFullName + '|' +  @AccountNumber + '|' +  @DestCurrency  + '|' +  Cast(@DestAmount as varchar)
  
  


  SELECT @PublicKey=PublicKey
    FROM ImxDirectSecurity.dbo.ImxDirect_AgencyComputerCertificates
   WHERE Thumbprint = @CertificateThumprint

  SELECT @TestAgency=TestAgency
	FROM WireSearch.dbo.Agencies
  WHERE AgencyCode = @AgSenderCode

EXEC @CLRResult=SqlCLR.dbo.ImxDirect_VerifySignature @PublicKey,@SignedData,@Signature
  if (@CLRResult = 0 and @TestAgency = 0)
	BEGIN
	  SET @ErrorCode        = '11269' -- Signature Not Valid
	  SET @WireResult       = 500
	  SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	  SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
	  INSERT INTO dbo.ImxDirect_SignedDataErrorLog (AgSenderCode,DT,SignedData ,Signature)
                                            VALUES (@AgSenderCode,getdate(),@SignedData ,@Signature)
	  RETURN
	END
	


  if EXISTS (Select AgencyCode FROM WireSearch.dbo.Agencies Where AgencyCode = @AgSenderCode and WebAgent = 1)
     BEGIN
       SET @ErrorCode = '10653' -- Invalid Agency
	   SET @WireResult       = 500
	   SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)+' Agency '+@AgSenderCode
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
	   RETURN
     END

  if @AgPayerCode is null or RTRIM(ltrim(@AgPayerCode)) = ''
    begin
      SET @ErrorCode = '11179' -- Payer cannot be blank
	  SET @WireResult       = 500
	  SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	  SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) 
	  RETURN
    END

  if @OriToDestExRate is null or @OriToDestExRate <= 0
    begin
      SET @ErrorCode = '10227' -- Invalid Exchange Rate, Please check if that Payer is setup properly
	  SET @WireResult       = 500
	  SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	  SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) 
	  RETURN 
    END

   

   if (@SenderId = 0 or @SenderId is null) and @SenderGroupId > 0
     Set @SenderGroupId = 0

   Set @ReCalcTotalAmount = IsNull(@OriAmount, 0) + IsNull(@Charges, 0) + IsNull(@OtherChg, 0) + 
                            IsNull(@AgencyFee, 0) + IsNull(@WireStateFee, 0) + 
                            IsNull(@WireSenderPaymentMethodFee, 0) + IsNull(@CashBackAmount, 0) - IsNull(@DiscountAmount, 0)
          
   if Abs(ROUND(@ReCalcTotalAmount, 2) - @WireTotalAmount) > 0.01
    begin
      SET @ErrorCode = '10838' -- Invalid Total Amount
	  SET @WireResult       = 500
	  SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	  SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) 
	  RETURN   
    END
   
   		--Nuevas validaciones para FX  Geru Jul 09 2018
   IF @DestCurrency = @OriCurrency
  AND @OriToDestExRate <> 1
   begin
      SET @ErrorCode = '10227' -- Invalid Exchange Rate, Please check if that Payer is setup properly
	  SET @WireResult       = 500
	  SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	  SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) 
	  RETURN   
    END

 IF @DestCurrency <> @OriCurrency
      BEGIN
	    DECLARE @FxVariationAllowed decimal(10,4)

	    select @FxVariationAllowed = FxVariationAllowed
		  from WireSearch.dbo.Geo_Countries
	     where Countryname = @DestCountry
	
	    DECLARE @ValidFX decimal(10,4) = 0
		DECLARE @ValidFXDif decimal(10,4) = 0
	    EXEC WirePricing.dbo.Prc_WireGetOnlyFX_FXRedesign  @AgSenderCode	,@AgPayerCode ,@OriCurrency,		
                                                @DeliveryType   ,@TranTypeID  ,@DestCountry,		
                                                @DestCurrency	,@OriAmount	,@ValidFX OUTPUT	
        IF @ValidFX IS NULL OR @ValidFX = 0
		   begin
             SET @ErrorCode = '10227' -- Invalid Exchange Rate, Please check if that Payer is setup properly
			 SET @WireResult       = 500
			 SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
			 SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) 
			 RETURN 
		   END
		SET @ValidFXDif = (@OriToDestExRate - ISNULL(@FXPointsAdded,0)) - @ValidFX
		IF  ABS(ROUND(@ValidFXDif,0)) > @FxVariationAllowed
		  BEGIN
             SET @ErrorCode = '10227' -- Invalid Exchange Rate, Please check if that Payer is setup properly
	         SET @WireResult       = 500
	         SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	         SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) 
	         RETURN 
          END 
	  END

  select @D = GETDATE(), @DateOnly = CAST(GETDATE() as Date)
  Set @IP =  dbo.GetCurrentIP()  



  Set @Result = 0


  if @SenderID <= 0 or @SenderID is null or @ReceiverID = 0 or @ReceiverID is null
    Set @DoItNow = 1
  ELSE  
    SET @DoItNow = 0

  select @InsSender = 0, @InsReceiver = 0, 
         @LSenderID = null, @LReceiverID = null,
         @WireDatetime = GETDATE(), @WireDate = dbo.DateOnly(GETDATE())

    SELECT @CreatedBy = UserName
	  FROM WireSearch.dbo.AgenciesLogins
	 WHERE AgLoginId = @AgUserId

	 Set @WireInfoForLog = rtrim(@AgSenderCode) + ', ' + rtrim(@SndFullName) + ',' + cast(@OriAmount as varchar)
 

  --------Sender information-------------
  select @SenderID = IsNull(@SenderID, 0), 
         @SndLastVersionId = ISNULL(@SndLastVersionId, 0) 

  if @SenderID > 0
    begin
      select top 1 @LSenderID = LSenderid 
      from Senders with(nolock) where Senderid = @SenderID

      IF @LSenderID IS NULL
        SET @InsSender = 1
    END
  ELSE --SenderID = 0 or null
    BEGIN
      SELECT TOP 1 @LSenderID = LSenderId 
      FROM Senders with(nolock) 
      WHERE SndFullName = @SndFullName and 
            SndFirstName = @SndFirstName and SndLast1 = @SndLast1 and IsNull(SndLast2, '') = IsNull(@SndLast2, '') and
            SndAddress = @SndAddress and SndCity = @SndCity and SndState = @SndState and
            SndCountry = @SndCountry and SndZip = @SndZip and SndPhone = @SndPhone and
            SndNoSecLastName = @SndNoSecLastName and 
          -- SndIdTypeName = @SndIdTypeName and SndIdNumber = @SndIdNumber and SndIdCountry = @SndIdCountryName and 
          -- SndIdState = @SndIdStateName and IsNull(SndIdExpirationDate, 0) = IsNull(@SndIdExpirationDate, 0) and
             (SenderId = 0 or SenderId is null)

     IF @LSenderID IS NULL
       SET @InsSender = 1 
    END
	if rtrim(@SndIdType) <> ''
	   BEGIN
	     SELECT @SndIdTypeName = IdTypeName
		   FROM WireCompliance.dbo.Comp_IdTypes
		  WHERE [IdType] = @SndIdType
	   END  
  if (@OptStatusOpper = 'I' OR @OptStatusPromo = 'I')
      SET @IsCellPhone = 1

  if @InsSender = 1
    begin
	  INSERT INTO Senders with(rowlock) 
	 		     (SenderId, SenderGroupId, SndFullName, SndFirstName, SndLast1, SndLast2, 
				  SndAddress, SndCountry, SndState, SndCity, SndZip,
				  SndPhone, SndLastVersionId, SndNoSecLastName, 
				  SndIdTypeName, SndIdNumber, SndIdCountry, SndIdState, SndIdExpirationDate,
				  IsCellPhone, OptStatus, OptStatusDate,OptStatusPromo, Citizenship)
		   VALUES
			     (@SenderId, @SenderGroupId, @SndFullName, @SndFirstName, @SndLast1, @SndLast2, 
				  @SndAddress, @SndCountry, @SndState, @SndCity, @SndZip,
				  @SndPhone, @SndLastVersionId, @SndNoSecLastName, 
				  @SndIdTypeName, @SndIdNumber, @SndIdCountryName, @SndIdStateName, @SndIdExpirationDate,
				  @IsCellPhone, @OptStatusOpper, @DateOnly,@OptStatusPromo, @Nationality)
      SET @LSenderID = SCOPE_IDENTITY()
      -- Check
    END
  ELSE 
    BEGIN
 	 UPDATE Senders with(updlock)
	    SET SenderId = @SenderId,     SndFullName = @SndFullName, SndFirstName = @SndFirstName,
   		    SndLast1 = @SndLast1,     SndLast2 = @SndLast2,       SndAddress = @SndAddress,
   		    SndCountry = @SndCountry, SndState = @SndState,       SndCity = @SndCity,
   		    SndZip = @SndZip,         SndPhone = @SndPhone,       SndLastVersionId = @SndLastVersionId,
   		    SndNoSecLastName = @SndNoSecLastName, IsCellPhone = @IsCellPhone, 
   		    OptStatus = @OptStatusOpper, OptStatusDate = @DateOnly, OptStatusPromo = @OptStatusPromo,
   		   -- SndIdTypeName = @SndIdTypeName, SndIdNumber = @SndIdNumber, SndIdCountry = @SndIdCountryName, 
   		   -- SndIdState = @SndIdStateName, SndIdExpirationDate = @SndIdExpirationDate
		    Citizenship = @Nationality
     WHERE LSenderId = @LSenderID
     -- Update Information if You Have IdInformation for AgPayerIdRequirement
     IF ( LEN(RTRIM(@SndIdTypeName)) > 0 AND LEN(RTRIM(@SndIdNumber)) > 0 )
		BEGIN
			IF ( LEN(RTRIM(@SndIdCountryName)) = 0 AND LEN(RTRIM(@SndIdStateName)) = 0  AND @SndIdExpirationDate IS NULL)
				BEGIN
				-- Just Update Id Type Name and Id Number
					UPDATE Senders WITH (UPDLOCK)
						SET SndIdTypeName = @SndIdTypeName , SndIdNumber = @SndIdNumber
					WHERE LSenderId = @LSenderID;				
				END	
			ELSE
				BEGIN
				-- Update All Fields
					UPDATE Senders WITH (UPDLOCK)
						SET SndIdTypeName = @SndIdTypeName 
						, SndIdNumber = @SndIdNumber
						, SndIdCountry = @SndIdCountryName
						, SndIdState = @SndIdStateName
						, SndIdExpirationDate = @SndIdExpirationDate
					WHERE LSenderId = @LSenderID;								
				END		
		END
    END

  ---------Receiver info-----------
  select @ReceiverId = IsNull(@ReceiverId, 0), 
         @RcvLastVersionID = ISNULL(@RcvLastVersionID, 0) 

  if @ReceiverId > 0
    begin
      select top 1 @LReceiverID = LReceiverId 
      from Receivers with(nolock) where ReceiverId = @ReceiverId

      IF @LReceiverID IS NULL
        SET @InsReceiver = 1
    END
  ELSE
    BEGIN
      SELECT top 1 @LReceiverID = LReceiverId 
      FROM Receivers with(nolock)
      WHERE RcvFullName = @RcvFullName and
            RcvFirstName = @RcvFirstName and RcvLast1 = @RcvLast1 and IsNull(RcvLast2, '') = IsNull(@RcvLast2, '') AND
            RcvAddress = @RcvAddress and  RcvCity = @RcvCity and
            RcvState = @RcvState and RcvCountry = @RcvCountry and
            IsNull(RcvZip, '') = IsNull(@RcvZip, '') and IsNull(RcvPhone, '') = IsNull(@RcvPhone, '') and IsNull(CPF, '') = IsNull(@CPF, '') and
            (ReceiverId = 0 or ReceiverId is null) 

      IF @LReceiverID IS NULL
        SET @InsReceiver = 1
    END 

  IF isnull(@RcvLast2,'') = ''
     BEGIN
	   SET @RcvNoSecLastName =1
	   SET @RcvLast2 = ''
	 END
  if @InsReceiver = 1
    begin
  	  INSERT INTO Receivers with(rowlock)
	  		     (ReceiverId, ReceiverGroupId, RcvFullName, RcvFirstName,
			      RcvLast1, RcvLast2, RcvAddress, RcvCountry,
			      RcvState, RcvCity, RcvZip, RcvPhone,
			      RcvNoSecLastName, RcvLastVersionID, CPF, Entered, RcvDOB)
		 VALUES
	  		     (@ReceiverId, @ReceiverGroupId, @RcvFullName, @RcvFirstName,
			      @RcvLast1, @RcvLast2, @RcvAddress, @RcvCountry,
			      @RcvState, @RcvCity, @RcvZip, @RcvPhone,
			      @RcvNoSecLastName, @RcvLastVersionID, @CPF, GETDATE(), @RcvDOB)

	  SELECT @LReceiverID = SCOPE_IDENTITY()	      
    END  
  ELSE
    BEGIN
      UPDATE Receivers WITH(UPDLOCK)
         SET ReceiverId = @ReceiverId,     ReceiverGroupId = @ReceiverGroupId,
             RcvFullName = @RcvFullName,   RcvFirstName = @RcvFirstName,
             RcvLast1 = @RcvLast1,         RcvLast2 = @RcvLast2,
             RcvAddress = @RcvAddress,     RcvCountry = @RcvCountry,
             RcvState = @RcvState,         RcvCity = @RcvCity,
             RcvZip = @RcvZip,             RcvPhone = @RcvPhone,
             RcvNoSecLastName = @RcvNoSecLastName, 
             RcvLastVersionID = @RcvLastVersionID,
             CPF = @CPF,
             RcvDOB = @RcvDOB
       WHERE LReceiverId = @LReceiverID    
    END 

  exec SQLMAIN.[WireTransac].dbo.CFPB_CalculateWireAvailableDate_3 @WireDatetime, @AgPayerCode, @BranchId,
                                                                 0, @TranTypeID, 
                                                                 @SourceApp, @WireReplacementType,@WireAvailableDate output
--//////////////////LOYALTY
  SET @PointsTranType = ''

  IF @AcumLoyaltyPoints = 1  --Esta en el Loyalty Program
    BEGIN
	  IF @CRMPromotionId IS NOT NULL AND @CRMPromotionId <> 0
	 AND  EXISTS (Select CRMPromotionId FROM WirePricing.dbo.CRM_PointsRedemptionSetUp  --En este giro hace Redeem de puntos
	               Where CRMPromotionId = @CRMPromotionId AND Status = 'A')
		   BEGIN
		     SET @PointsTranType = 'REDEEM'
		     SET @WirePoints     = @PointsToRedeem
			 SET @WirePointsSign = -1 
		   END
      ELSE BEGIN   ---Este giro suma puntos
	        SET @PointsTranType = 'WIRE'
	       END
	END

	IF @PointsTranType = 'WIRE'
	   BEGIN   ---Este giro suma puntos
	     EXEC CRM_MakeWire_LoyaltyPointsManager @AgSenderCode ,@AgSenderSeq ,
                                                @SameSenderId ,@TranTypeID ,'WIRE',0 ,0,@PointsAdded  OUTPUT
	     SET @WirePoints     = @PointsAdded
		 SET @WirePointsSign = 1
	   END

--//////////////////END LOYALTY--------------------

  BEGIN TRY


SET XACT_ABORT ON
  BEGIN TRAN   
  ---Get PIN Number
  if rtrim(@PinNumber) = '' or @PinNumber is null
    exec WireKeys.dbo.sps_GetPINNumber @AgPayerCode, @PinNumber output  
  IF @PinNumber IS NULL
     BEGIN
	     SET @ErrorCode = '11307' -- There was on error creating the PIN NUMBER, Please call Technical Support
	     SET @WireResult       = 500
	     SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)+' Agency '+@AgSenderCode+' Payer '+@AgPayerCode
	     SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) --There was on error creating the PIN NUMBER, Please call Technical Support
	     RETURN
	   END
     

  ---Agency Sequence Number  
  exec WireKeys.dbo.sps_GenAgencySeq @AgSenderCode, @AgSenderSeq output  

  SET @OriAmount          = ROUND(@OriAmount,2)
  SET @DestAmount         = ROUND(@DestAmount,2)
  SET @WireTotalAmount    = ROUND(@WireTotalAmount,2)
  SET @AgSenderCommission = ROUND(@AgSenderCommission,2)


  --===== A partir del 1.1.2017
  SET @AgencyExtraFee = 0
  SET @AgencyExtraFee     = @AgencyFee
  SET @Charges            = @Charges            + @AgencyExtraFee
  SET @AgSenderCommission = @AgSenderCommission + @AgencyExtraFee

  --------Insert Transfer-------
  INSERT INTO Wires with(rowlock)
           (LSenderId ,LReceiverId ,AgSenderId ,AgSenderCode, 
            AgSenderSeq ,AgSenderState ,AgSenderCity ,AgSenderCountry, 
            AgPayerId ,AgPayerCode ,DestCountry ,DestState, 
            DestCity ,BranchId ,SenderId ,OnBehalfId,
            ReceiverId ,SenderName ,OnBehalfName ,ReceiverName,
            PinNumber ,WireDate ,WireDatetime ,OriAmount,
            OriCurrency ,Charges ,OtherChg ,AgencyFee,
            OriToDestExRate, WireStateFee,
            WireTotalAmount ,DestAmount ,DestCurrency ,AgSenderCommission,
            FXPointsAdded,FXChangeCost,FXCostApplyTo,
            TranTypeID ,AccountNumber ,DeptBankName ,AccountType,
            DeptAdditionalInfo ,BankBranchCode ,DeliveryType ,SourceApp,
            StsComplianceOk ,StsCancel ,CustTrasactionID, RateTypeID,PayerPayMethodId,
            FeePlanID, FxPlanID, AgCommiPlanID, FXDif, FXShare_id,
            WirePurpose, FundSource, Occupation, SndEmployerName, SndEmployerPhone, SenderIdRecId,
            IncomingPhoneNumber ,CallerIDVerif ,TeledirectWire ,NoFaxBackWire,
            ReplacedControl ,WaivedCharges, ReplaceWireRcvSel, WireReplacementType ,ReplacementReasonID, 
            MemberCardSwiped ,CreatedBy ,ComputerName, CustMessage, ExRateMacro, SndDOB,SndRcvRelationship,
            NewTelewire, AgComputerid, ComputerId, AppVersion, TkDelay, FeeChange, CostToAgent ,CostToCustomer,
            FlexPrcOptionSelected, PayerSecToken, WireAvailableDate, ClientIP,
            DiscountAmount, PromoCostToCompany, PromoCostToAgent, PromoCostToPayer, CRMPromotionId, SenderPromoUniqueKey,
            LoyaltyCardNumber, WirePoints, WirePointsSign, AcumLoyaltyPoints, AgencyExtraFee,
			CardChargeId, SenderPaymentMethodId, WireSenderPaymentMethodFee, CashBackAmount, TransacTotalAmount, 
			AgPayerRcvIdTypeRecordId, RcvIdNumber,WiresAlreadyCountGUID,F1025AgentFullName, AgencyPricingId,
			AgencyPricingDetailId, FxBaseId, FXPromotionId, FxBase, AgencyFXPointsFromBase, AgencyPromoFXPoints)
     VALUES
           (@LSenderID, @LReceiverID, @AgSenderId, @AgSenderCode,
            @AgSenderSeq, @AgSenderState, @AgSenderCity, @AgSenderCountry,
            @AgPayerId, @AgPayerCode, @DestCountry, @DestState,
            @DestCity, @BranchId, @SenderId, 0,
            @ReceiverId, @SndFullName, null, @RcvFullName,
            @PinNumber, @WireDate, @WireDatetime, @OriAmount,
            @OriCurrency, @Charges, @OtherChg, @AgencyFee,
            @OriToDestExRate, @WireStateFee,
            @WireTotalAmount, @DestAmount, @DestCurrency, @AgSenderCommission,
            @FXPointsAdded,@FXChangeCost,@FXCostApplyTo,
            @TranTypeID, @AccountNumber, @DeptBankName, @AccountType,
            @DeptAdditionalInfo, @BankBranchCode, @DeliveryType, @SourceApp,
            @StsComplianceOk, 0, 0, @RateTypeID,@PayerPayMethodId,
            @FeePlanID, @FxPlanID, @AgCommiPlanID, @FXDif, @FXShare_id, 
            @WirePurpose, @FundSource, @Occupation, @SndEmployerName, @SndEmployerPhone, @SenderIdRecId,
            '', 0, 0, 0,
            @ReplacedControl, @WaivedCharges, @ReplaceWireRcvSel, @WireReplacementType, @ReplacementReasonID,
            @MemberCardSwiped, @CreatedBy, @ComputerName, @MessageToRcv, 1, @EnteredSndDOB,@SndRcvRelationship,
            0, @AgComputerId, @FingerPrint, @AppVersion, @Delay, @FeeChange, @CostToAgent , @CostToCustomer,
            @FlexPrcOptionSelected, '', @WireAvailableDate, @ClientIP,
            @DiscountAmount, @PromoCostToCompany, @PromoCostToAgent, @PromoCostToPayer, @CRMPromotionId, @SenderPromoUniqueKey,
            @LoyaltyCardNumber, @WirePoints, @WirePointsSign, @AcumLoyaltyPoints, @AgencyExtraFee,
			@CardChargeId, @SenderPaymentMethodId, @WireSenderPaymentMethodFee, @CashBackAmount, @WireTotalAmount,
			ISNULL(@AgPayerRcvIdTypeRecordId,0), ISNULL(@RcvIdNumber,0),@WiresAlreadyCountGUID,@1025AgentFullName,
			@AgencyPricingId, @AgencyPricingDetailId, @FxBaseId, @FXPromotionId, @FxBase, @AgencyFXPointsFromBase, 
			@AgencyPromoFXPoints)

  select @WireId = SCOPE_IDENTITY()

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

  if  @FxPlanID = 0 and ltrim(@OriCurrency) <> LTRIM(@DestCurrency)
    insert into dbo.LogFxRateIdEmpty(AgencyCode, AgSenderSeq, WireId)
        values(@AgSenderCode, @AgSenderSeq, @WireId)

--  exec PossibleFraudeCheck 2, @WireId, @AgCompID, @ComputerName, @Result, @AgSenderCode, @CreatedBy, @Token, @PswHash, @InsertPossibleFraud output 


--------------------------------------------------------------------------------------------------------------------
	if @ComplianceHitsFound = 1 or @StsComplianceOk = 0
    begin
      UPDATE WireCompliance.dbo.Comp_WireOnHold with(updlock) Set WireId = @WireId
      WHERE GuidId = @Compliance_GUID

      UPDATE WireCompliance.dbo.LogAmountWarnMsg WITH(UPDLOCK) SET Wire_ID = @WireId,
																   StorePerson = CAST(@1025AgentFullName AS VARCHAR(125))
      WHERE CompGuidId = @Compliance_GUID
    END

  if @SenderPaymentMethodId <> 5 --Card Direct
    begin
	--  insert TEST(Msg, NUM, N1) values('Wire Id', @WireID, @WireTotalAmount) 
      INSERT INTO ProcessedWires with(rowlock) (WireID, Done) Values(@WireID, 0)
	end

  if @SenderPaymentMethodId = 5 --Card Direct
    begin
	  DECLARE @Tag varchar(20)
	  --SET @Tag = rtrim(@AgSenderCode)+convert(varchar,@AgSenderSeq)
	  SET @Tag = rtrim(@AgSenderCode)+'-'+convert(varchar,@AgSenderSeq)
	  INSERT INTO dbo.WiresTAG   (WireTAG           ,WireID           ,PswHash           ,AppHash           ,AgComputerid           ,Created)
	     VALUES (@Tag,@WireId,NULL,NULL,@AgComputerId,GETDATE())
	END

  -- IRS REQUEST
     IF EXISTS (Select * FROM WireCompliance.dbo.Comp_WiresOnIRSHold Where GuidId  = @Compliance_GUID)
	    begin
		  UPDATE WireCompliance.dbo.Comp_WiresOnIRSHold with(updlock) Set WireId = @WireId
           WHERE GuidId = @Compliance_GUID
		end
  -- END IRS REQUEST
 
  exec WireCompliance.dbo.spi_Create_CumulativeSummaryAmountsToday_DestCurrency
            @WireId,
			@OriAmount, @DestAmount,--New
			@SndFullName, @OriCurrency, 
			@SndCountry, @AgSenderState, @AgSenderCity,
			@RcvFullName, @DestCurrency,
			@DestCountry, @DestState, @DestCity,
			@SndPhone, @RcvPhone,
			@DeptBankName, @AccountNumber, @AgPayerCode

 UPDATE [dbo].[ImxDirect_WireCFPBLog] WITH(UPDLOCK) SET WireId  = @WireId
  WHERE [PreparationId]  = @PreparationId 

  COMMIT TRAN;

  IF @PointsTranType = 'REDEEM' and @WireReplacementType <> 2
     BEGIN
       EXEC CRM_MakeWire_LoyaltyPointsManager @AgSenderCode ,@AgSenderSeq ,
                                              @SameSenderId ,@TranTypeID ,'REDEEM',@PointsToRedeem ,@PointsRedemptionId,@PointsAdded  OUTPUT
     END
  
  INSERT INTO ImxDirect_WirePricingInfo (WireId
							   ,PreparationId
							   ,PreparationDatetime
							   ,AgSenderCode
							   ,AgPayerCode
							   ,DestCountryAbbr
							   ,TranTypeId
							   ,DeliveryType
							   ,SenderPaymentMethodId
							   ,OriCurrencyCode
							   ,OriAmount
							   ,AgPlanAssignId
							   ,FeePlanID
							   ,CommPlanID
							   ,ExRatePlanID
							   ,FXDif
							   ,FXShareId
							   ,RateTypeId
							   ,PriceAffectedBy
							   ,PlanFeeAmount
							   ,WireFeeAmount
							   ,PlanCommissionAmount
							   ,WireCommissionAmount
							   ,PlanEXRate
							   ,WireEXRate
							   ,DestAmount
							   ,DestCurrencyCode
							   ,WireStateFee
							   ,DiscountAmount
							   ,AgencyFee
							   ,PromotionId
							   ,PromoCode
							   ,PromoType
							   ,PromoCost
							   ,PromoCostToCompany
							   ,PromoCostToAgent
							   ,PromoCostToPayer
							   ,PromoFxDif
							   ,PromoFxCost
							   ,PromoResultWirePoints
							   ,WiresAlreadyCountGUID
							   ,PointsToRedeem
							   ,PointsRedemptionId
							   ,PointsRedemptionType
							   ,PointsRedemptionValue
							   ,PointsRedemptionCost
							   ,FlexPriceOption
							   ,FlexPriceValueApplied
							   ,FlexPriceCost
							   ,FlexPriceCostApplyTo
							   ,PayerPromId
							   ,PayerPromFxAdded
							   ,DestAmountMultipleOf
							   ,DestAmountIsOK
							   ,StsComplianceOk
							   ,SenderPaymentMethodFee)
   SELECT @WireId
          ,PreparationId
		  ,PreparationDatetime
		  ,AgSenderCode
		  ,AgPayerCode
		  ,DestCountryAbbr
		  ,TranTypeId
		  ,DeliveryType
		  ,SenderPaymentMethodId
		  ,OriCurrencyCode
		  ,OriAmount
		  ,AgPlanAssignId
		  ,FeePlanID
		  ,CommPlanID
		  ,ExRatePlanID
		  ,FXDif
		  ,FXShareId
		  ,RateTypeId
		  ,PriceAffectedBy
		  ,PlanFeeAmount
		  ,WireFeeAmount
		  ,PlanCommissionAmount
		  ,WireCommissionAmount
		  ,PlanEXRate
		  ,WireEXRate
		  ,DestAmount
		  ,DestCurrencyCode
		  ,WireStateFee
		  ,DiscountAmount
		  ,AgencyFee
		  ,PromotionId
		  ,PromoCode
		  ,PromoType
		  ,PromoCost
		  ,PromoCostToCompany
		  ,PromoCostToAgent
		  ,PromoCostToPayer
		  ,PromoFxDif
		  ,PromoFxCost
		  ,PromoResultWirePoints
		  ,WiresAlreadyCountGUID
		  ,PointsToRedeem
		  ,PointsRedemptionId
		  ,PointsRedemptionType
		  ,PointsRedemptionValue
		  ,PointsRedemptionCost
		  ,FlexPriceOption
		  ,FlexPriceValueApplied
		  ,FlexPriceCost
		  ,FlexPriceCostApplyTo
		  ,PayerPromId
		  ,PayerPromFxAdded
		  ,DestAmountMultipleOf
		  ,DestAmountIsOK
		  ,StsComplianceOk
		  ,SenderPaymentMethodFee
    FROM ImxDirect_WireInPreparation
   WHERE PreparationId = @PreparationId
     AND AgSenderCode  = @AgSenderCode
  IF @@ROWCOUNT = 1
     BEGIN
	  DELETE FROM ImxDirect_WireInPreparation
	   WHERE PreparationId = @PreparationId
		 AND AgSenderCode  = @AgSenderCode
	 END

  IF @DoItNow = 1
    UPDATE BridgeProcessNow WITH(UPDLOCK) SET DoItNow = 1  


----==========================================================================GERU==========================================================
  INSERT INTO ImxDirect_PerformanceLog(Sp,PreparationId ,AgSenderCode ,Step ,StepTime )
                               VALUES ('ImxDirect_WIRE_CreateAWireTransfer_V4',@PreparationId,@AgSenderCode,2,GETDATE())
----===========================================================================================================================================


  END TRY
  BEGIN CATCH
   DECLARE @ErrorMessage VARCHAR(4000);

   SET @ErrorMessage = ERROR_MESSAGE()
   SET @ErrorMessage = @WireInfoForLog + ' ' + ISNULL(@ErrorMessage, '')

    IF @@TRANCOUNT > 0
      ROLLBACK TRAN;

    SET @WireResult = 1
	--INSERT INTO dbo.ErrorLog (ProcessName, ErrorMsg) values('ImxDirect_WIRE_CreateAWireTransfer', @ErrorMessage)
	SET @ErrorCode = '11283' -- An Unexpected error has occurred, please try again and if the error persists contact technical support
	SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)

  END CATCH  
END TRY
BEGIN CATCH
    SET @WireResult = 1
    SET @ErrorCode = '11283' -- An Unexpected error has occurred, please try again and if the error persists contact technical support
	SET @LogErrorMessage  = ERROR_MESSAGE() ---dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)

	SET @LogErrorMessage = RTRIM(@LogErrorMessage)
	--exec spi_Error_LOG2 'CREATE WIRE IMXDIRECT', @LogErrorMessage

END CATCH
