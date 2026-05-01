-- =============================================
-- Author:		Antonio Salgado
-- Create date: 10 Feb 2021
-- Description:	Updates the WireInProgress record associated with the PraparationId passed. Also, insterts a new record in WireInProgress FX
-- =============================================
CREATE   PROCEDURE [dbo].[WebApi_UpdateWireInPreparation]
	@PreparationId uniqueidentifier,
	@CurrentWebLanguageId int,
	@ChannelId int,
	@PartnerId int,
	@TranTypeId int,
	@AgSenderCode varchar(10),
	@AgSenderId   int,
	@FxRate money,
	@DestAmount money,
	@FeeAmount money,
	@StateTax money = 0,
	@WebFeeId int,
	@WebExRateId int,
	@OriAmount money,
	@DestCountry VARCHAR(30),	
	@DestCurrency varchar(3),
	@AgPayerCode varchar(15),
	@LegalEntityCode varchar(10)
AS
BEGIN

Declare @SenderPaymentMethodId int 
Declare @StyleId int
Declare @UserPaymentMethodInfoId int

Select @SenderPaymentMethodId = SenderPaymentMethodId , @StyleId = StyleId, @UserPaymentMethodInfoId = UserPaymentMethodId
							  from PaymentDataEntry.dbo.WebAgent_WireInPreparation
							  Where PreparationId = @PreparationId

if (@SenderPaymentMethodId not in (select SenderPaymentMethodId from Wiresearch.dbo.WebAgent_SenderPaymentMethodByStyle where StyleId = @StyleId and IsAvailable = 1 ))
	begin
		set @SenderPaymentMethodId = 0
		set @UserPaymentMethodInfoId = null
	end

	 UPDATE PaymentDataEntry.dbo.WebAgent_WireInPreparation SET AgSenderCode         = @AgSendercode,
			                                                AgSenderId            = @AgSenderId,
															FXAmount              = @FxRate,
                                                            DestAmount            = @DestAmount,
                                                            FeeAmount             = @FeeAmount,
                                                            StateTax              = @StateTax,
															SndCommissionAmount   = 0,
															FeePlanID             = @WebFeeId,
															CommPlanID            = 0,
															RatePlanID            = @WebExRateId,
															FXDif                 = 0,
															FXShareId             = 0,
															OriAmount             = @OriAmount,
															DestCountry           = @DestCountry,
															DestCurrency          = @DestCurrency,
															ChannelId             = @ChannelId,
															FXPayerCode           = @AgPayerCode,
															LegalEntityCode       = @LegalEntityCode,
															PartnerId             = @PartnerId,
															SenderPaymentMethodId = @SenderPaymentMethodId,
															UserPaymentMethodId   = @UserPaymentMethodInfoId
	WHERE PreparationId = @PreparationId	
END