CREATE procedure [dbo].[ImxDirect_WIRE_CreateAWireTransfer_V4_OldJun24_2020]
(
    @PreparationId uniqueidentifier,
	@CurrentLanguageId int,
	--Senders
	@SenderId int,
	@SenderGroupId int,
	@SndFirstName varchar(50),
	@SndLast1 varchar(50),
	@SndLast2 varchar(50) ,
	@SndAddress varchar(50),
	@SndCountry varchar(30),
	@SndState varchar(30),
	@SndCity varchar(40),
	@SndZip varchar(15),
	@SndPhone varchar(20),
	@SndLastVersionId int,
	@SndNoSecLastName bit,
	@IsCellPhone bit,
	-- Fields add for AgPayerIdRequirements -- ( Payers that required Id over certain amount )
    @SndIdType varchar(5),
    @SndIdNumber varchar(80),
    @SndIdCountryName varchar(30),
    @SndIdStateName varchar(40),
    @SndIdExpirationDate datetime,
	--CRM
	@SameSenderId int , -- New x Loyalty
	@AcumLoyaltyPoints bit, --New x Loyalty
	@PointsToRedeem int, --New x Loyalty
	@PointsRedemptionId int, --New x Loyalty
    @OptStatusOpper char(1),
	@OptStatusPromo char(1),
	@MemberCardSwiped bit,
	@LoyaltyCardNumber varchar(50),
   

    --Receivers
	@ReceiverId int,
	@ReceiverGroupId int,
	@RcvFirstName varchar(50),
	@RcvLast1 varchar(50),
	@RcvLast2 varchar(50),
	@RcvAddress varchar(200),
	@RcvCountry varchar(30),
	@RcvState varchar(30),
	@RcvCity varchar(40),
	@RcvZip varchar(15),
	@RcvPhone varchar(20),
	@RcvNoSecLastName bit,
	@RcvLastVersionID int,
	@CPF varchar(11),
	@RcvDOB datetime,
	@MessageToRcv varchar(255),

	--Wire info
	@AgSenderId int,
	@AgSenderCode varchar(10),
	@AgSenderState varchar(30),
	@AgSenderCity varchar(40),
	@AgSenderCountry varchar(30),

	@AgPayerId int,
	@AgPayerCode varchar(10),
	@DestCountry varchar(30),
	@DestState varchar(30),
	@DestCity varchar(40),
	@BranchId int,
	@PayerPromoId int, --New

	--Transaction
	@TranTypeID int,
	@DeliveryType char(1),
	@SourceApp int,
	--Amounts
	@AgPlanAssignId int, --new
	@OriAmount money,
	@OriCurrency char(3),
	@Charges money,
	@OtherChg money,
	@AgencyFee money,
	@OriToDestExRate money,
	@WireStateFee money,
	@WireTotalAmount money,
	@DestAmount money,
	@DestCurrency char(3),
	@AgSenderCommission money,
	@DiscountAmount MONEY, 

		

	
	--Deposit
	@AccountNumber varchar(30),
	@DeptBankName varchar(60),
	@AccountType smallint,
	@DeptAdditionalInfo varchar(60),
	@BankBranchCode varchar(7),
	@AgPayerRcvIdTypeRecordId int, 
	@RcvIdNumber varchar(80),

	
	--CFPB
	@UserAcceptCFPB varchar(50),  --New (crearlo en wires y pasarlo x el bridge)

	--Compliance
	@EnteredSndDOB datetime,
	@WirePurpose varchar(200),
	@FundSource varchar(120),
	@Occupation varchar(80),
	@SndRcvRelationship varchar(80),
	@SndEmployerName varchar(120),
	@SndEmployerPhone varchar(20),
	@SenderIdRecId int,
	@Compliance_GUID uniqueidentifier,
	@StsComplianceOk bit,
	@ComplianceHitsFound bit,
	@Electronic1025 bit, --Nuevo version 4!!!!!!!!!!!!!!!!!!!!!!!
	@1025AgentFullName varchar(150),--1025 without sign


	--WireReplacement
	@ReplacedControl int,
	@WaivedCharges money,
	@ReplaceWireRcvSel int,
	@WireReplacementType int,
	@ReplacementReasonID int,


	--Card Direct
	@CardChargeId int,
	@SenderPaymentMethodId int,
	@WireSenderPaymentMethodFee money,
	@CashBackAmount money,
	@CardDirectProviderId int,


	--Security
	@AgComputerId int          ,
	@FingerPrint  varchar(200),
	@ComputerName varchar(100),
	@AgUserId     int          ,
    @AppVersion varchar(50),
   --@Token varchar(200),
   --@WireTAG varchar(15),
   --@AppHash varbinary(32),
   --@PswHash  varbinary(32),
    @ClientIP varchar(50),

	--Signature
	@CertificateThumprint varchar(100),
	@Signature varbinary(max),

	--OUTPUT
    @WireId int output,
    @AgSenderSeq int output,
	@PinNumber varchar(20) output, 
    @WireDatetime datetime output,
    @WireAvailableDate datetime output,
	@WireResult int OUTPUT, --- 0 = ok, 1 = no grabo error no controlado, 500 Error de alguna validacion
    @ErrorCode varchar(10) OUTPUT,
    @UserErrorMessage varchar(300) OUTPUT,
    @LogErrorMessage varchar(MAX) OUTPUT
)     
as  
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
		@WiresAlreadyCountGUID uniqueidentifier


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
	     @SenderPromoUniqueKey  = '',
		 @WiresAlreadyCountGUID = WiresAlreadyCountGUID,
		 @StsComplianceOk       = StsComplianceOk
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

  SET @SndFirstName = rtrim(ltrim(@SndFirstName))
  SET @SndLast1  = rtrim(ltrim(@SndLast1))
  SET @SndLast2 = Rtrim(ltrim(@SndLast2))

  SET @RcvFirstName = rtrim(ltrim(@RcvFirstName))
  SET @RcvLast1 = rtrim(ltrim(@RcvLast1))
  SET @RcvLast2 = Rtrim(ltrim(@RcvLast2))

  SET @SndFullName =rtrim(@SndFirstName+' '+@SndLast1+' '+@SndLast2)
  SET @RcvFullName =rtrim(@RcvFirstName+' '+@RcvLast1+' '+@RcvLast2)
  SET @SignedData = @AgSenderCode + '|' + @SndFullName  + '|' +  @RcvFullName + '|' +  @AccountNumber + '|' +  @DestCurrency  + '|' +  Cast(@DestAmount as varchar)
  
  


  SELECT @PublicKey=PublicKey
    FROM ImxDirectSecurity.dbo.ImxDirect_AgencyComputerCertificates
   WHERE Thumbprint = @CertificateThumprint


EXEC @CLRResult=SqlCLR.dbo.ImxDirect_VerifySignature @PublicKey,@SignedData,@Signature
  if (@CLRResult = 0)
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
    end

  if @OriToDestExRate is null or @OriToDestExRate <= 0
    begin
      SET @ErrorCode = '10227' -- Invalid Exchange Rate, Please check if that Payer is setup properly
	  SET @WireResult       = 500
	  SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	  SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) 
	  RETURN 
    end

   

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
    end
   
   		--Nuevas validaciones para FX  Geru Jul 09 2018
   IF @DestCurrency = @OriCurrency
  AND @OriToDestExRate <> 1
   begin
      SET @ErrorCode = '10227' -- Invalid Exchange Rate, Please check if that Payer is setup properly
	  SET @WireResult       = 500
	  SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	  SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) 
	  RETURN   
    end

 IF @DestCurrency <> @OriCurrency
      BEGIN
	    DECLARE @FxVariationAllowed decimal(10,4)

	    select @FxVariationAllowed = FxVariationAllowed
		  from WireSearch.dbo.Geo_Countries
	     where Countryname = @DestCountry
	
	    DECLARE @ValidFX decimal(10,4) = 0
		DECLARE @ValidFXDif decimal(10,4) = 0
	    EXEC WirePricing.dbo.Prc_WireGetOnlyFX  @AgSenderCode	,@AgPayerCode ,@OriCurrency,		
                                                @DeliveryType   ,@TranTypeID  ,@DestCountry,		
                                                @DestCurrency	,@RateTypeID  ,0	,@ValidFX OUTPUT	
        IF @ValidFX IS NULL OR @ValidFX = 0
		   begin
             SET @ErrorCode = '10227' -- Invalid Exchange Rate, Please check if that Payer is setup properly
			 SET @WireResult       = 500
			 SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
			 SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) 
			 RETURN 
		   end
		SET @ValidFXDif = (@OriToDestExRate - ISNULL(@FXPointsAdded,0)) - @ValidFX
		IF  ABS(round(@ValidFXDif,0)) > @FxVariationAllowed
		  begin
             SET @ErrorCode = '10227' -- Invalid Exchange Rate, Please check if that Payer is setup properly
	         SET @WireResult       = 500
	         SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	         SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) 
	         RETURN 
          end 
	  END

  select @D = GETDATE(), @DateOnly = CAST(GETDATE() as Date)
  Set @IP =  dbo.GetCurrentIP()  



  Set @Result = 0


  if @SenderID <= 0 or @SenderID is null or @ReceiverID = 0 or @ReceiverID is null
    Set @DoItNow = 1
  else  
    Set @DoItNow = 0

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

      if @LSenderID is null
        Set @InsSender = 1
    end
  else --SenderID = 0 or null
    begin
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

     if @LSenderID is null
       Set @InsSender = 1 
    end
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
				  IsCellPhone, OptStatus, OptStatusDate,OptStatusPromo)
		   VALUES
			     (@SenderId, @SenderGroupId, @SndFullName, @SndFirstName, @SndLast1, @SndLast2, 
				  @SndAddress, @SndCountry, @SndState, @SndCity, @SndZip,
				  @SndPhone, @SndLastVersionId, @SndNoSecLastName, 
				  @SndIdTypeName, @SndIdNumber, @SndIdCountryName, @SndIdStateName, @SndIdExpirationDate,
				  @IsCellPhone, @OptStatusOpper, @DateOnly,@OptStatusPromo)
      Set @LSenderID = SCOPE_IDENTITY()
      -- Check
    end
  else 
    begin
 	 UPDATE Senders with(updlock)
	    SET SenderId = @SenderId,     SndFullName = @SndFullName, SndFirstName = @SndFirstName,
   		    SndLast1 = @SndLast1,     SndLast2 = @SndLast2,       SndAddress = @SndAddress,
   		    SndCountry = @SndCountry, SndState = @SndState,       SndCity = @SndCity,
   		    SndZip = @SndZip,         SndPhone = @SndPhone,       SndLastVersionId = @SndLastVersionId,
   		    SndNoSecLastName = @SndNoSecLastName, IsCellPhone = @IsCellPhone, 
   		    OptStatus = @OptStatusOpper, OptStatusDate = @DateOnly, OptStatusPromo = @OptStatusPromo--,
   		   -- SndIdTypeName = @SndIdTypeName, SndIdNumber = @SndIdNumber, SndIdCountry = @SndIdCountryName, 
   		   -- SndIdState = @SndIdStateName, SndIdExpirationDate = @SndIdExpirationDate
     WHERE LSenderId = @LSenderID
     -- Update Information if You Have IdInformation for AgPayerIdRequirement
     IF ( LEN(RTRIM(@SndIdTypeName)) > 0 AND LEN(RTRIM(@SndIdNumber)) > 0 )
		BEGIN
			IF ( LEN(RTRIM(@SndIdCountryName)) = 0 AND LEN(RTRIM(@SndIdStateName)) = 0  AND @SndIdExpirationDate is null)
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

      if @LReceiverID is null
        Set @InsReceiver = 1
    end
  else
    begin
      SELECT top 1 @LReceiverID = LReceiverId 
      FROM Receivers with(nolock)
      WHERE RcvFullName = @RcvFullName and
            RcvFirstName = @RcvFirstName and RcvLast1 = @RcvLast1 and IsNull(RcvLast2, '') = IsNull(@RcvLast2, '') AND
            RcvAddress = @RcvAddress and  RcvCity = @RcvCity and
            RcvState = @RcvState and RcvCountry = @RcvCountry and
            IsNull(RcvZip, '') = IsNull(@RcvZip, '') and IsNull(RcvPhone, '') = IsNull(@RcvPhone, '') and IsNull(CPF, '') = IsNull(@CPF, '') and
            (ReceiverId = 0 or ReceiverId is null) 

      if @LReceiverID is null
        Set @InsReceiver = 1
    end 

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
			      RcvNoSecLastName, RcvLastVersionID, CPF)
		 VALUES
	  		     (@ReceiverId, @ReceiverGroupId, @RcvFullName, @RcvFirstName,
			      @RcvLast1, @RcvLast2, @RcvAddress, @RcvCountry,
			      @RcvState, @RcvCity, @RcvZip, @RcvPhone,
			      @RcvNoSecLastName, @RcvLastVersionID, @CPF)

	  select @LReceiverID = SCOPE_IDENTITY()	      
    end  
  else
    begin
      UPDATE Receivers with(updlock)
         SET ReceiverId = @ReceiverId,     ReceiverGroupId = @ReceiverGroupId,
             RcvFullName = @RcvFullName,   RcvFirstName = @RcvFirstName,
             RcvLast1 = @RcvLast1,         RcvLast2 = @RcvLast2,
             RcvAddress = @RcvAddress,     RcvCountry = @RcvCountry,
             RcvState = @RcvState,         RcvCity = @RcvCity,
             RcvZip = @RcvZip,             RcvPhone = @RcvPhone,
             RcvNoSecLastName = @RcvNoSecLastName, 
             RcvLastVersionID = @RcvLastVersionID,
             CPF = @CPF
       WHERE LReceiverId = @LReceiverID    
    end 

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

  ----Libera 1025 Electronica
   -- IF @StsComplianceOk = 0
   --AND @Electronic1025 = 1
   --    BEGIN
	  --   EXEC WireCompliance.dbo.Comp_ProcessElectronic1025 @PreparationId ,@StsComplianceOk  output
	  -- END





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
			AgPayerRcvIdTypeRecordId, RcvIdNumber,WiresAlreadyCountGUID,F1025AgentFullName)
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
			ISNULL(@AgPayerRcvIdTypeRecordId,0), ISNULL(@RcvIdNumber,0),@WiresAlreadyCountGUID,@1025AgentFullName)

  select @WireId = SCOPE_IDENTITY()

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

  if  @FxPlanID = 0 and ltrim(@OriCurrency) <> LTRIM(@DestCurrency)
    insert into dbo.LogFxRateIdEmpty(AgencyCode, AgSenderSeq, WireId)
        values(@AgSenderCode, @AgSenderSeq, @WireId)

--  exec PossibleFraudeCheck 2, @WireId, @AgCompID, @ComputerName, @Result, @AgSenderCode, @CreatedBy, @Token, @PswHash, @InsertPossibleFraud output 


--------------------------------------------------------------------------------------------------------------------

  if @SenderPaymentMethodId <> 5 --Card Direct
    begin
	--  insert TEST(Msg, NUM, N1) values('Wire Id', @WireID, @WireTotalAmount) 
      INSERT INTO ProcessedWires with(rowlock) (WireID, Done) Values(@WireID, 0)
	end

  if @SenderPaymentMethodId = 5 --Card Direct
    begin
	  DECLARE @Tag varchar(20)
	  SET @Tag = rtrim(@AgSenderCode)+'-'+convert(varchar,@AgSenderSeq)
	  INSERT INTO dbo.WiresTAG   (WireTAG           ,WireID           ,PswHash           ,AppHash           ,AgComputerid           ,Created)
	     VALUES (@Tag,@WireId,null,null,@AgComputerId,getdate())
	end

  if @ComplianceHitsFound = 1 or @StsComplianceOk = 0
    begin
      UPDATE WireCompliance.dbo.Comp_WireOnHold with(updlock) Set WireId = @WireId
      WHERE GuidId = @Compliance_GUID

      UPDATE WireCompliance.dbo.LogAmountWarnMsg WITH(updlock) SET Wire_ID = @WireId,
																   StorePerson = CAST(@1025AgentFullName as varchar(125))
      WHERE CompGuidId = @Compliance_GUID
    end
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

  IF @PointsTranType = 'REDEEM'
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

  if @DoItNow = 1
    update BridgeProcessNow with(updlock) set DoItNow = 1  


----==========================================================================GERU==========================================================
  insert into ImxDirect_PerformanceLog(Sp,PreparationId ,AgSenderCode ,Step ,StepTime )
                               values ('ImxDirect_WIRE_CreateAWireTransfer_V4',@PreparationId,@AgSenderCode,2,getdate())
----===========================================================================================================================================


  END TRY
  BEGIN CATCH
   DECLARE @ErrorMessage VARCHAR(4000);

   Set @ErrorMessage = ERROR_MESSAGE()
   Set @ErrorMessage = @WireInfoForLog + ' ' + IsNull(@ErrorMessage, '')

    if @@TRANCOUNT > 0
      rollback TRAN;

    Set @WireResult = 1
	--INSERT INTO dbo.ErrorLog (ProcessName, ErrorMsg) values('ImxDirect_WIRE_CreateAWireTransfer', @ErrorMessage)
	SET @ErrorCode = '11283' -- An Unexpected error has occurred, please try again and if the error persists contact technical support
	SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)

  END CATCH  
END TRY
BEGIN CATCH
    Set @WireResult = 1
    SET @ErrorCode = '11283' -- An Unexpected error has occurred, please try again and if the error persists contact technical support
	SET @LogErrorMessage  = ERROR_MESSAGE() ---dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)

	SET @LogErrorMessage = rtrim(@LogErrorMessage)
	--exec spi_Error_LOG2 'CREATE WIRE IMXDIRECT', @LogErrorMessage

END CATCH