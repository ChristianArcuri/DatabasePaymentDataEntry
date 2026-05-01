CREATE procedure [dbo].[ImxDirect_WIRE_ChangeOfBeneficiary_Replacement]
(	
	@PreparationId				uniqueidentifier,
	@CurrentLanguageId			INT, 
	@TypeOfChangeOfBeneficiary	INT, -- 1 - Beneficiary Name Mispell, 0 -- New Benefiary
	@Control					INT,
	@UserName					VARCHAR(20),
	@LocationId					INT,
	@ComputerName				VARCHAR(100),
	@SourceApp					INT,

    @AgSenderCode				VARCHAR(10),
	@AgComputerId				INT,
	@FingerPrint				VARCHAR(200),
	@AgUserId					INT,
	@AppVersion					VARCHAR(50),
	@ClientIP					VARCHAR(50),
	@StsComplianceOk			BIT,

	--Signature
	@CertificateThumprint		VARCHAR(100),
	@Signature					VARBINARY(max),

	@ReceiverId					INT,
		
	--New Beneficiary Name
	@NewFirstName				VARCHAR(50),
	@NewLast1					VARCHAR(50),
	@NewLast2					VARCHAR(50),
	@NewPhone					VARCHAR(20),
	
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
   	@ChangeOfBeneficiaryResult	INT				OUTPUT, -- 0 = ok, 1 = no grabo error no controlado, 500 Error de alguna validacion
    @ErrorCode					VARCHAR(10)		OUTPUT,
    @UserErrorMessage			VARCHAR(300)	OUTPUT,
    @LogErrorMessage			VARCHAR(MAX)	OUTPUT,
	@WireId						INT				OUTPUT
	
)
AS
 	SET NOCOUNT ON;

	DECLARE 
			-- AgSender
			@AgSenderId				    INT,
			@AgState					VARCHAR(30),
			@AgCity						VARCHAR(40),
			@AgCountry					VARCHAR(30),

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
			@SndLastVersionId			INT,
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
			@ReceiverGroupId			INT,
			@RcvPhone					VARCHAR(20),
			@RcvFirstName				VARCHAR(50),
			@RcvLast1					VARCHAR(50),
			@RcvLast2					VARCHAR(50),
			@RcvAddress					VARCHAR(50),
			@RcvCountry					VARCHAR(30),
			@RcvState					VARCHAR(30),
			@RcvCity					VARCHAR(40),
			@RcvZip						VARCHAR(15),
			@RcvNoSecLastName			BIT,
			@RcvLastVersionID			INT,
			@CPF						VARCHAR(11),
			@RcvIdNumber				VARCHAR(80),
				
			-- WireAmountInfo
			@DestAmount					MONEY,
			@DestCurrency				CHAR(3),
			@DestCountry				VARCHAR(50),
			@OriAmount					MONEY,
			@OriCurrency				CHAR(3),
			@DestCity					VARCHAR(30),
			@DestState					VARCHAR(30),
			@WireTotalAmount			MONEY,
			@OriCountry					VARCHAR(50),
			@OriState					VARCHAR(50),
			@OriCity					VARCHAR(50),
			@DestCountryAbbr			CHAR(3),
			@DeliveryType				CHAR(1),
			@SenderPaymentMethodId		INT,

			@AgPlanAssignId				INT,
			@ExRatePlanID				INT,
			@FeeAmount					MONEY,
			@FeePlanID					INT,
			@FXDif						MONEY,
			@FXShareId					INT,
			
			@PriceAffectedBy			VARCHAR(10),
			@CommPlanID					INT,
			@RatePlanID					INT,
			@RateTypeID					INT,
			@PlanFeeAmount				MONEY,
			@WireFeeAmount				MONEY,
			@PlanCommissionAmount		MONEY,
			@WireCommissionAmount		MONEY,
			@PlanEXRate					MONEY,
			@WireEXRate					MONEY,
			@AgencyFee					MONEY,
			@PayerPromId				INT,

			@PromotionId				INT,
			@PromoCode					VARCHAR(20),
			@PromoCost					MONEY,
			@PayerPromFxAdded			DECIMAL(10,4),
			@PromoCostToCompany			MONEY,
			@PromoCostToAgent			MONEY,
			@PromoCostToPayer			MONEY,
			@PromoResultWirePoints		INT,
			@WiresAlreadyCountGUID		UNIQUEIDENTIFIER,
			@PromoFxDif					DECIMAL(10,4),
			@PromoFxCost				MONEY,
			@PointsToRedeem				INT,
			@PointsRedemptionId			INT,
			@PointsRedemptionType		VARCHAR(5),
			@PointsRedemptionValue		DECIMAL(10,4),
			@PointsRedemptionCost		MONEY,
			@FlexPriceOption			CHAR(3),
			@FlexPriceValueApplied		DECIMAL(10,4),
			@FlexPriceCost				MONEY,
			@FlexPriceCostApplyTo		CHAR(1),
				  
			@DestAmountMultipleOf		MONEY,
			@DestAmountIsOK				BIT,
			@DiscountAmount				MONEY,

			@MemberCardSwiped			BIT,
			-- wirePayerBranchInfo
			@AgPayerId					INT,
			@AgPayerCode				CHAR(10),
			@BranchId					INT,
			
			-- WireDepositInfo
			@AccountNumber				VARCHAR(50),
			@DeptBankName				VARCHAR(50),
			--
			@TranTypeId					INT,
			@ErrorInt					INT = 0,

			@OriToDestExRate			MONEY,
			@AccountType				SMALLINT,
			@DeptAdditionalInfo			VARCHAR(60),
			@BankBranchCode				VARCHAR(7),
			@AgPayerRcvIdTypeRecordId	INT,
			@AcumLoyaltyPoints			BIT,
			@WaivedCharges				MONEY,
			@CashBackAmount				MONEY,

			@LogChangeInfoId			INT = 0,
	        @PreparationDate			DATETIME,

			@AgencyPricingId			INT,   --New FX Redesign
			@AgencyPricingDetailId		INT,   --New FX Redesign
			@FxBaseId					INT,   --New FX Redesign
			@FXPromotionId				INT,   --New FX Redesign
			@FxBase						MONEY, --New FX Redesign
			@AgencyFXPointsFromBase		MONEY, --New FX Redesign
			@AgencyPromoFXPoints		MONEY, --New FX Redesign

			-- Create Wire Result
			@WireResult					INT = 0,

			@Nationality				VARCHAR(50)

	--- Set initial values
	SET @ChangeOfBeneficiaryResult   = 0
	SET @ErrorCode					 = ''
	SET @UserErrorMessage			 = ''
	SET @LogErrorMessage			 = ''
	SET @AgSenderCode				 = LTRIM(RTRIM(@AgSenderCode))
	SET @WireId						 = 0

	BEGIN TRY 

		IF NOT EXISTS(SELECT 1 FROM sqlmain.wiretransac.dbo.Wires WHERE Control = @Control and SourceApp = 46)
		BEGIN
			EXEC CD_Wire_Replacement 
				@CurrentLanguageId, 
				@TypeOfChangeOfBeneficiary,
				@Control,
				@UserName,
				@LocationId,
				@ComputerName,
				@StsComplianceOk,
				@ReceiverId,
				@AgSenderCode,
				@AgComputerId,
				@CertificateThumprint,
				@Signature,
				@NewFirstName,
				@NewLast1,
				@NewLast2,
				@NewPhone,
				@ComplianceHitsFound,
				@1025AgentFullName,
				@Electronic1025,
				@IdSelected,
				@EnteredSndDOB,
				@WirePurpose,
				@FundSource,
				@Occupation,
				@SndRcvRelationship,
				@SndEmployerName,
				@SndEmployerPhone,
				@SenderIdRecId,
		
				--OUTPUT
				@ChangeOfBeneficiaryResult	= @ChangeOfBeneficiaryResult OUTPUT,
				@ErrorCode					= @ErrorCode OUTPUT,
				@UserErrorMessage			= @UserErrorMessage OUTPUT,
				@LogErrorMessage			= @LogErrorMessage OUTPUT,
				@WireId						= @WireId	OUTPUT

			RETURN
		END

		SELECT TOP 1
		  		  @AgSenderId			= W.AgSenderId,
				  @AgState				= ag.AgState,
				  @AgCity				= ag.AgCity,
				  @AgCountry			= ag.AgCountry,

				   -- Sender  -- Sender,
				  @SenderId				= s.SenderId,
				  @SenderGroupId		= S.SenderGroupId,
				  @SndVersionId			= W.SndVersionId,
				  @SndFirstName			= S.SndFirstName,
				  @SndLast1				= S.SndLast1,
				  @SndLast2				= S.SndLast2,
				  @SndAddress			= S.SndAddress,
				  @SndCountry			= S.SndCountry,
				  @SndState				= S.SndState,
				  @SndCity				= S.SndCity,
				  @SndZip				= S.SndZip,
				  @SndPhone				= S.SndPhone,
				  @SndLastVersionId		= W.SndVersionId, 
				  @SndNoSecLastName		= S.NoSecLastName,
				  @IsCellPhone			= S.IsCellPhone,
				  @SameSenderId			= S.SameSenderId,
				  @OptStatusOpper		= ss.OptStatus, 
				  @OptStatusPromo		= ss.OptStatusPromo,
				  @Nationality			= S.SndCitizenship,	
				
				   -- Receiver  -- Receiver,
				  --@RcvPhone				= R.RcvPhone,
				  @RcvAddress			= R.RcvAddress,
				  @RcvCountry			= R.RcvCountry,
				  @RcvState				= R.RcvState,
				  @RcvCity				= R.RcvCity,
				  @RcvZip				= R.RcvZip,
				  @RcvNoSecLastName		= R.NoSecLastName,
				  @RcvLastVersionID		= R.LastVersionID,
				  @CPF					= R.CPF,
				  @RcvIdNumber			= W.RcvIdNumber,
				  @ReceiverGroupId		= R.ReceiverGroupId,
								 				
				  ---- WireAmountInfo  -- WireAmountInfo,
				  @DestAmount			= W.DestAmount,
				  @DestCurrency			= W.DestCurrency,
				  @DestCity				= W.DestCity,
				  @DestState            = W.DestState      ,
				  @OriAmount			= W.OriAmount,
				  @OriCurrency			= W.OriCurrency,
				  @WireTotalAmount      = W.WireTotalAmount,
				  @DeliveryType			= W.DeliveryType,
				  @SenderPaymentMethodId = 1, --W.SenderPaymentMethodId,
				  @DestCountry			= W.DestCountry,

				  @AgPlanAssignId		= wpi.AgPlanAssignId, 
				  @PriceAffectedBy		= wpi.PriceAffectedBy, 
				  @ExRatePlanID			= WP.ExRatePlanID, 
				  @FeeAmount			= W.Charges,
				  @FeePlanID			= WP.FeePlanID,
				  @FXDif				= WP.FXDif, 
				  @FXShareId			= WP.FxShareId,  
				  @OriToDestExRate		= W.OriToDestExRate,

				  @CommPlanID			= WP.AgCommiPlanID,				
				  @RatePlanID			= wpi.ExRatePlanID,
				  @RateTypeID			= W.RateTypeID,				
				  @PlanFeeAmount		= wpi.PlanFeeAmount,
				  @WireFeeAmount		= wpi.WireFeeAmount,			
				  @PlanCommissionAmount	= wpi.PlanCommissionAmount,
				  @WireCommissionAmount	= wpi.WireCommissionAmount,
				  @PlanEXRate			= wpi.PlanEXRate,
				  @WireEXRate			= wpi.WireEXRate,
				  @AgencyFee			= W.AgencyFee,

				  @PayerPromId			= wpi.PayerPromId,		
				  @PayerPromFxAdded		= wpi.PayerPromFxAdded, 	  
				  @DestAmountMultipleOf	= wpi.DestAmountMultipleOf, 
				  @DestAmountIsOK		= wpi.DestAmountIsOK, 
				  @PayerPromFxAdded		= wpi.PayerPromFxAdded,
				  @DiscountAmount		= wpi.DiscountAmount,

				  @PromotionId			= wpi.PromotionId,
				  @PromoCode			= wpi.PromoCode,
				  @PromoCost			= wpi.PromoCost,
				  @PromoCostToCompany	= wpi.PromoCostToCompany,	
				  @PromoCostToAgent		= wpi.PromoCostToAgent,		  
				  @PromoCostToPayer		= wpi.PromoCostToPayer,		
				  @PromoResultWirePoints= wpi.PromoResultWirePoints,
				  @WiresAlreadyCountGUID= wpi.WiresAlreadyCountGUID,	
				  @PromoFxDif			= wpi.PromoFxDif,			  
				  @PromoFxCost			= wpi.PromoFxCost,				
				  @PointsToRedeem		= CASE WHEN W.WirePointsSign = -1 THEN W.WirePoints ELSE 0 END,  ---if wires.wirepointsign is not null and = -1 then wires.wirepoint
				  @PointsRedemptionId	= wpi.PointsRedemptionId,	
				  @PointsRedemptionType	= wpi.PointsRedemptionType,	  
				  @PointsRedemptionValue= wpi.PointsRedemptionValue,	
				  @PointsRedemptionCost	= wpi.PointsRedemptionCost,
				  @FlexPriceOption		= wpi.FlexPriceOption,		
				  @FlexPriceValueApplied= wpi.FlexPriceValueApplied,	  
				  @FlexPriceCost		= wpi.FlexPriceCost,			
				  @FlexPriceCostApplyTo = wpi.FlexPriceCostApplyTo,
				 
	
				  -- wirePayerBranchInfo      -- wirePayerBranchInfo,
				  @AgPayerId			= W.AgPayerId,
				  @AgPayerCode			= W.AgPayerCode,
				  @BranchId             = W.BranchId,
				
				  -- WireDepositInfo      -- WireDepositInfo,
				  @AccountNumber		= W.AccountNumber,
				  @TranTypeId			= W.TranTypeId,
				  
				  @DestCountryAbbr		= wpi.DestCountryAbbr,
				  @MemberCardSwiped		= ISNULL(W.MemberCardSwiped,0),

				  @SndIdType			= '', 
				  @SndIdNumber			= '', 
				  @SndIdCountryName		= '',  
				  @SndIdStateName		= '',  
				  @SndIdExpirationDate	= null,  

				  @AccountType			= W.AccountTypeId,
				  @DeptAdditionalInfo	= W.DeptAdditionalInfo,
				  @BankBranchCode		= W.BankBranchCode,
				  @AgPayerRcvIdTypeRecordId = W.AgPayerRcvIdTypeRecordId,
				  
				  @AcumLoyaltyPoints	= CASE WHEN ISNULL(W.WirePoints,0) > 0 THEN 1 ELSE 0 END, ---  if wires.wirepoint is not null and  > 0 then 1 else 0
				  @WaivedCharges		= W.Charges + W.OtherChg,
				  @CashBackAmount		= W.CashBackAmount,

				  --FX Redesign
				  @AgencyPricingId			= p.AgencyPricingId,
				  @AgencyPricingDetailId	= p.AgencyPricingDetailId,
				  @FxBaseId					= p.FxBaseId,
				  @FXPromotionId			= p.FXPromotionId,
				  @FxBase					= p.FxBase,
				  @AgencyFXPointsFromBase	= p.AgencyFXPointsFromBase,
				  @AgencyPromoFXPoints		= p.AgencyPromoFXPoints
	  FROM	sqlmain.wiretransac.dbo.Wires as W
			  INNER JOIN  sqlmain.wiretransac.dbo.Agencies ag on W.AgSenderCode = ag.AgencyCode
			  INNER JOIN sqlmain.wiretransac.dbo.SenderVersions as S ON S.SenderId = W.SenderId and S.SndVersionId = W.SndVersionId
			  INNER JOIN sqlmain.wiretransac.dbo.Senders ss ON S.SenderId = ss.SenderId
			  INNER JOIN sqlmain.wiretransac.dbo.Receivers as R ON R.ReceiverId = W.ReceiverId
			  INNER JOIN [WirePricing].dbo.Prc_WirePlans WP ON WP.[Control] = W.Control 
			  INNER JOIN sqlmain.wiretransac.dbo.WiresCrossReference wcr on W.Control = wcr.Control
			  INNER JOIN PaymentDataEntry.dbo.ImxDirect_WirePricingInfo wpi on wcr.WireID = wpi.WireId
			  INNER JOIN WirePricing.dbo.Prc_WirePlans p on p.Control = W.Control
	  WHERE	W.[Control] = @Control;
	
	  IF @@Rowcount = 0
	   BEGIN
	     SET @ErrorCode = '11305' -- Could not find the preparation record
	     SET @ChangeOfBeneficiaryResult       = 500
	     SET @LogErrorMessage  = 'No record on wire - ' + ' Agency ' + @AgSenderCode
	     SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId) --The wire could not be saved, please close the transaciont window and try again
	     RETURN
	   END

	   

	 -- BEGIN TRAN

	   IF @Electronic1025 =1 AND @IdSelected = 1
	     EXEC WireCompliance.dbo.Comp_ProcessElectronic1025 @PreparationId, @StsComplianceOk OUTPUT
		 	
	
		
        
		--- Check if it requires new exrate
		IF EXISTS(SELECT 1
				  FROM sqlmain.wiretransac.[dbo].AgPayerTreasury AP 
				  WHERE AP.AgencyId = @AgPayerId
						AND ReplacementWireNewExRate = 1)
		BEGIN
					EXEC WireSearch.[dbo].[ImxDirect_WIRE_GetCharges_V6]
										@PreparationId,		@CurrentLanguageId,		@SenderPaymentMethodId,
										@AgSenderCode,		@AgPayerCode,			@AgPlanAssignId,
										'O',				@OriAmount,				0,
										0,					@OriCurrency,			@DeliveryType,	
										@TranTypeID,		@DestCountryAbbr,		@DestCurrency,										
										@CashBackAmount,

										0,
										@ChangeOfBeneficiaryResult OUTPUT,
										@ErrorCode				   OUTPUT,
										@UserErrorMessage		   OUTPUT,
										@LogErrorMessage		   OUTPUT,
											
										0,					0,						0,
										0,					0,						0,
										0,					0,						0,
										'',					'', 					0,
 										0,				    '', 				    0,
										'',					 0,						0

					IF @ChangeOfBeneficiaryResult > 0
						THROW 55000,@LogErrorMessage, 1
		END
		ELSE
		BEGIN
					SET @PreparationDate  = GETDATE()
					EXEC PaymentDataEntry.dbo.ImxDirect_WireInPreparation_Insert_FXRedesign 
										@PreparationId,				@PreparationDate,			@AgSenderCode,			@AgPayerCode,           
										@DestCountryAbbr,			@TranTypeID,				@DeliveryType,			@SenderPaymentMethodId ,
										@DestCurrency,				@OriCurrency,				@OriAmount,				@AgPlanAssignId, 

										@PriceAffectedBy,			@FeePlanID,					@CommPlanID,			@RatePlanID,        
                                        @FXDif,						@FXShareId,					@RateTypeID,			@PlanFeeAmount,         
										@WireFeeAmount,				@PlanCommissionAmount,		@WireCommissionAmount,	@PlanEXRate,   
                                        @WireEXRate,				@DestAmount,				0,						@DiscountAmount,   
															
										@AgencyFee,					@PromotionId,				@PromoCode,				@PromoCost,
										@PromoCostToCompany,		@PromoCostToAgent,			@PromoCostToPayer,		@PromoResultWirePoints,
										@WiresAlreadyCountGUID,		@PromoFxDif,				@PromoFxCost,			@PointsToRedeem,
															
										@PointsRedemptionId,		@PointsRedemptionType,		@PointsRedemptionValue,	@PointsRedemptionCost,
										@FlexPriceOption,			@FlexPriceValueApplied,		@FlexPriceCost,			@FlexPriceCostApplyTo,
										@PayerPromId,				@PayerPromFxAdded,			@DestAmountMultipleOf,	@DestAmountIsOK,
										@AgencyPricingId,			@AgencyPricingDetailId,		@FxBaseId,				@FXPromotionId,
										@FxBase,					@AgencyFXPointsFromBase,	@AgencyPromoFXPoints 
		 END
		
		
		UPDATE PaymentDataEntry.dbo.ImxDirect_WireInPreparation SET StsComplianceOk = @StsComplianceOk
		 WHERE PreparationId = @PreparationId

	  -- Create new ReplacemnetWire: ImxDirect_WIRE_CreateAWireTransfer_V4 

	    SET @WireTotalAmount = ISNULL(@OriAmount, 0) + ISNULL(@AgencyFee, 0) + ISNULL(@CashBackAmount, 0)

		EXEC PaymentDataEntry.[dbo].[ImxDirect_WIRE_CreateAWireTransfer_V4]

					@PreparationId		=	@PreparationId,
					@CurrentLanguageId	=	@CurrentLanguageId,
					
					--Senders
					@SenderId			=	@SenderId,
					@SenderGroupId		=	@SenderGroupId,
					@SndFirstName		=	@SndFirstName,
					@SndLast1			=	@SndLast1,
					@SndLast2			=	@SndLast2 ,
					@SndAddress			=	@SndAddress,
					@SndCountry			=	@SndCountry,
					@SndState			=	@SndState,
					@SndCity			=	@SndCity,
					@SndZip				=	@SndZip,
					@SndPhone			=	@SndPhone,
					@SndLastVersionId	=	@SndLastVersionId,
					@SndNoSecLastName	=	@SndNoSecLastName,
					@IsCellPhone		=	@IsCellPhone,

					@SndIdType			=	@SndIdType,
					@SndIdNumber		=	@SndIdNumber,
					@SndIdCountryName	=	@SndIdCountryName,
					@SndIdStateName		=	@SndIdStateName,
					@SndIdExpirationDate =	@SndIdExpirationDate,
				
					--CRM
					@SameSenderId		=	@SameSenderId, 
					@AcumLoyaltyPoints	=	@AcumLoyaltyPoints,   
					@PointsToRedeem		=	@PointsToRedeem, 
					@PointsRedemptionId =	@PointsRedemptionId,
					@OptStatusOpper		=	@OptStatusOpper, 
					@OptStatusPromo		=	@OptStatusPromo,
					@MemberCardSwiped	=	@MemberCardSwiped,
					@LoyaltyCardNumber	=	'',  ----- creo que puede quedar en ''
   
					--Receivers
					@ReceiverId			=	@ReceiverId,
					@ReceiverGroupId	=	@ReceiverGroupId,
					@RcvFirstName		=	@NewFirstName,
					@RcvLast1			=	@NewLasT1,
					@RcvLast2			=	@NewLast2,
					@RcvAddress			=	@RcvAddress,
					@RcvCountry			=	@RcvCountry,
					@RcvState			=	@RcvState,
					@RcvCity			=	@RcvCity,
					@RcvZip				=	@RcvZip,
					@RcvPhone			=	@NewPhone, --@RcvPhone,
					@RcvNoSecLastName	=	@RcvNoSecLastName,
					@RcvLastVersionID	=	@RcvLastVersionID,
					@CPF				=	@CPF,
					@RcvDOB				=	NULL, --- this parameter is not used when create the wire 
					@MessageToRcv		=	'', 

					--Wire info
					@AgSenderId			=	@AgSenderId,
					@AgSenderCode       =   @AgSenderCode,
					@AgSenderState		=	@AgState,
					@AgSenderCity		=	@AgCity,
					@AgSenderCountry	=	@AgCountry,

					@AgPayerId			=	@AgPayerId,
					@AgPayerCode		=	@AgPayerCode,
					@DestCountry		=	@DestCountry,
					@DestState			=	@DestState,
					@DestCity			=	@DestCity,
					@BranchId			=	@BranchId,
					@PayerPromoId		=	@PayerPromId, 

					--Transaction
					@TranTypeID			=	@TranTypeID,
					@DeliveryType		=	@DeliveryType,
					@SourceApp			=	@SourceApp,
					
					--Amounts
					@AgPlanAssignId		=	@AgPlanAssignId, 
					@OriAmount			=	@OriAmount,
					@OriCurrency		=	@OriCurrency,
					@Charges			=	0,
					@OtherChg			=	0,
					@AgencyFee			=	@AgencyFee,
					@OriToDestExRate	=	@OriToDestExRate,
					@WireStateFee		=	0,
					@WireTotalAmount	=	@WireTotalAmount,
					@DestAmount			=	@DestAmount,
					@DestCurrency		=	@DestCurrency,
					@AgSenderCommission =	0,
					@DiscountAmount		=	0, 
	
					--Deposit
					@AccountNumber		=	@AccountNumber,
					@DeptBankName		=	@DeptBankName,
					@AccountType		=	@AccountType,
					@DeptAdditionalInfo =	@DeptAdditionalInfo,
					@BankBranchCode		=	@BankBranchCode,
					@AgPayerRcvIdTypeRecordId =	@AgPayerRcvIdTypeRecordId, 
					@RcvIdNumber		=	@RcvIdNumber,
	
					--CFPB
					@UserAcceptCFPB		=	'', ---------******* Cuando geru termine leerlo del wires

					--Compliance
					@EnteredSndDOB		=	@EnteredSndDOB,
					@WirePurpose		=	@WirePurpose,
					@FundSource			=	@FundSource,
					@Occupation			=	@Occupation,
					@SndRcvRelationship	=	@SndRcvRelationship,
					@SndEmployerName	=	@SndEmployerName,
					@SndEmployerPhone	=	@SndEmployerPhone,
					@SenderIdRecId		=	@SenderIdRecId,
					@Compliance_GUID	=	@PreparationId,
					@StsComplianceOk	=	@StsComplianceOk,
					@ComplianceHitsFound = @ComplianceHitsFound,
					@Electronic1025		=	@Electronic1025,
					@1025AgentFullName	=	@1025AgentFullName,

					--WireReplacement
					@ReplacedControl	=	@Control,
					@WaivedCharges		=	@WaivedCharges,
					@ReplaceWireRcvSel	=	@TypeOfChangeOfBeneficiary, --Si es misspell o cambio de nombre entero
					@WireReplacementType =	2,
					@ReplacementReasonID = 0,

					--Card Direct
					@CardChargeId		=	0,
					@SenderPaymentMethodId	=	@SenderPaymentMethodId,
					@WireSenderPaymentMethodFee =	0, 
					@CashBackAmount		=	@CashBackAmount,
					@CardDirectProviderId = 0,

					--Security
					@AgComputerId		=	@AgComputerId,
					@FingerPrint		=	@FingerPrint,
					@ComputerName		=	@ComputerName,
					@AgUserId			=	@AgUserId,
					@AppVersion			=	@AppVersion,
				    @ClientIP			=	@ClientIP,

					--Signature
					@CertificateThumprint =	@CertificateThumprint,
					@Signature			=	@Signature,
					@Nationality		=	@Nationality,

					--OUTPUT
					@WireId				= @WireId	OUTPUT,
					@AgSenderSeq		= 0	,
					@PinNumber			= '', 
					@WireDatetime		= NULL,
					@WireAvailableDate	= NULL,
					@WireResult			= @WireResult OUTPUT, --- 0 = ok, 1 = no grabo error no controlado, 500 Error de alguna validacion
					@ErrorCode			= @ErrorCode OUTPUT,
					@UserErrorMessage	= @UserErrorMessage OUTPUT,
					@LogErrorMessage	= @LogErrorMessage OUTPUT  


		IF @WireResult > 0
			THROW 55000,@LogErrorMessage, 1

	--   COMMIT TRAN


	  
	 
		-- Create Request of Cancellation for Original Wire
		EXEC sqlmain.wiretransac.[dbo].[ReqCancellation_Create] @control, 32, 1, @UserName, @LocationId, @LogChangeInfoId, @ErrorInt 
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
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
		SET @LogErrorMessage  =  'ImxDirect_WIRE_ChangeOfBeneficiary_Replacement - '+ ERROR_MESSAGE()


	END CATCH
