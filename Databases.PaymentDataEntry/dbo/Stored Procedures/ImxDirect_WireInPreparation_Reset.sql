CREATE PROCEDURE [dbo].[ImxDirect_WireInPreparation_Reset]
@PreparationId uniqueidentifier,
@AgSenderCode  varchar(10)
AS
BEGIN
  UPDATE PaymentDataEntry.dbo.ImxDirect_WireInPreparation SET PreparationDatetime  = getdate(),

	                                                        WireEXRate            = PlanEXRate,
															WireFeeAmount         = PlanFeeAmount,
															WireCommissionAmount  = PlanCommissionAmount,
															DestAmount            = round(OriAmount*PlanEXRate,2),
															DiscountAmount        = 0,
															PriceAffectedBy       = '',

															PromotionId           = 0,
															PromoCode             = '',
															PromoType             = '',
															PromoCost             = 0,
															PromoCostToCompany    = 0,
															PromoCostToAgent      = 0,
															PromoCostToPayer      = 0,
															PromoResultWirePoints = 0,
															PromoFxDif            = 0,
															PromoFxCost           = 0,
															WiresAlreadyCountGUID = null,

 
															PointsToRedeem        = 0,
															PointsRedemptionId    = 0,
															PointsRedemptionType  = '',
															PointsRedemptionValue = 0,
															PointsRedemptionCost  = 0,

															FlexPriceOption       = '',
															FlexPriceValueApplied = 0,
															FlexPriceCost         = 0,
															FlexPriceCostApplyTo  = '',

															PayerPromId           = 0,
                                                            PayerPromFxAdded      = 0,
															SenderPaymentMethodFee = 0

															
		WHERE PreparationId     = @PreparationId
          AND AgSenderCode      = @AgSenderCode

END