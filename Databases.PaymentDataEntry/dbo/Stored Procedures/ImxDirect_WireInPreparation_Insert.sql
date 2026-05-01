
CREATE PROCEDURE [dbo].[ImxDirect_WireInPreparation_Insert] 
 @PreparationId				uniqueidentifier,
 @PreparationDatetime		DATETIME,
 @AgSenderCode				CHAR(10),
 @AgPayerCode				CHAR(10),
 
 @DestCountryAbbr			CHAR(3),
 @TranTypeID				INT,
 @DeliveryType				CHAR(1),
 @SenderPaymentMethodId		INT,
 
 @DestCurrency				CHAR(3),	
 @OriCurrency				CHAR(3),
 @OriAmount					MONEY,				
 @AgPlanAssignId			INT,
 
 @PriceAffectedBy			VARCHAR(10),
 @FeePlanID					INT,
 @CommPlanID				INT,				
 @RatePlanID				INT,

 @FXDif						MONEY, 
 @FXShareId					INT,
 @RateTypeID				INT,				
 @PlanFeeAmount				MONEY,
	
 @WireFeeAmount				MONEY,			
 @PlanCommissionAmount		MONEY,	  
 @WireCommissionAmount		MONEY,	
 @PlanEXRate				MONEY,
		
 @WireEXRate				MONEY,
 @DestAmount				MONEY,
 @WireStateFee				MONEY,
 @DiscountAmount			MONEY,
	
 @AgencyFee					MONEY,
 @PromotionId				INT,
 @PromoCode					VARCHAR(20),				
 @PromoCost					MONEY,	
	
 @PromoCostToCompany		MONEY,	
 @PromoCostToAgent			MONEY,		  
 @PromoCostToPayer			MONEY,		
 @PromoResultWirePoints		INT,
		
 @WiresAlreadyCountGUID		UNIQUEIDENTIFIER,	
 @PromoFxDif				DECIMAL(10,4),			  
 @PromoFxCost				MONEY,				
 @PointsToRedeem			INT,

 @PointsRedemptionId		INT,	
 @PointsRedemptionType		VARCHAR(5),	  
 @PointsRedemptionValue		DECIMAL(10,4),	
 @PointsRedemptionCost		MONEY,
	
 @FlexPriceOption			CHAR(3),		
 @FlexPriceValueApplied		DECIMAL(10,4),	  
 @FlexPriceCost				MONEY,			
 @FlexPriceCostApplyTo		CHAR(1),
	
 @PayerPromId				INT,
 @PayerPromFxAdded			DECIMAL(10,4),	
 @DestAmountMultipleOf		MONEY,	
 @DestAmountIsOK			BIT
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.ImxDirect_WireInPreparation 
										(PreparationId,			PreparationDatetime,      AgSenderCode,				AgPayerCode,           
										DestCountryAbbr,		TranTypeId,	  			  DeliveryType,				SenderPaymentMethodId,
										DestCurrencyCode,		OriCurrencyCode,  		  OriAmount,				AgPlanAssignId, 

										PriceAffectedBy,		FeePlanID,  			  CommPlanID,				ExRatePlanID,
										FXDif,					FXShareId,     			  RateTypeid,				PlanFeeAmount,
										WireFeeAmount,			PlanCommissionAmount,     WireCommissionAmount,		PlanEXRate,
										WireEXRate,				DestAmount, 			  WireStateFee,				DiscountAmount,

										AgencyFee,				PromotionId,			  PromoCode,				PromoCost,
										PromoCostToCompany,		PromoCostToAgent,		  PromoCostToPayer,			PromoResultWirePoints,
										WiresAlreadyCountGUID,	PromoFxDif,				  PromoFxCost,				PointsToRedeem,

										PointsRedemptionId,		PointsRedemptionType,	  PointsRedemptionValue,	PointsRedemptionCost,
										FlexPriceOption,		FlexPriceValueApplied,	  FlexPriceCost,			FlexPriceCostApplyTo,
										PayerPromId,			PayerPromFxAdded,		  DestAmountMultipleOf,		DestAmountIsOK     )
						                                            
	
	VALUES (@PreparationId,			getdate(),				  @AgSenderCode,			@AgPayerCode,           
				@DestCountryAbbr,		@TranTypeID,			  @DeliveryType,			@SenderPaymentMethodId ,
				@DestCurrency,			@OriCurrency,			  @OriAmount,				@AgPlanAssignId, 

				@PriceAffectedBy,		@FeePlanID,				  @CommPlanID,				@RatePlanID,        
                @FXDif,					@FXShareId,				  @RateTypeID,				@PlanFeeAmount,         
				@WireFeeAmount,			@PlanCommissionAmount,	  @WireCommissionAmount,	@PlanEXRate,   
                @WireEXRate,			@DestAmount,			  0,						@DiscountAmount,   
															
				@AgencyFee,				@PromotionId,			  @PromoCode,				@PromoCost,
				@PromoCostToCompany,	@PromoCostToAgent,		  @PromoCostToPayer,		@PromoResultWirePoints,
				@WiresAlreadyCountGUID,	@PromoFxDif,			  @PromoFxCost,				@PointsToRedeem,
															
				@PointsRedemptionId,	@PointsRedemptionType,	  @PointsRedemptionValue,	@PointsRedemptionCost,
				@FlexPriceOption,		@FlexPriceValueApplied,	  @FlexPriceCost,			@FlexPriceCostApplyTo,
				@PayerPromId,			@PayerPromFxAdded,		  @DestAmountMultipleOf,	@DestAmountIsOK )
END
