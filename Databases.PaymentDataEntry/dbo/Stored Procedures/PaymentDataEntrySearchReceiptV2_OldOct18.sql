CREATE Procedure [dbo].[PaymentDataEntrySearchReceiptV2_OldOct18]
	@WireID int
As   
  Set nocount on;
  
	select W.WireId, W.AgSenderCode as AgencyCode, W.AgPayerCode as PayerCode, W.AgSenderSeq,
		W.WireDatetime, W.CreatedBy,
		S.SndFullName, S.SndAddress, S.SndCity, S.SndState, S.SndZip, S.SndPhone, S.SndCountry,
		R.RcvFirstName + ' ' + R.RcvLast1 + ' ' + R.RcvLast2 as RcvFullName, 
		R.RcvAddress, R.RcvCity, R.RcvState, R.RcvZip, R.RcvPhone, R.RcvCountry,
		W.OriAmount, 'USD' as OriCurrency,        
		W.Charges + W.OtherChg + (W.AgencyFee - ISNULL(w.AgencyExtraFee,0) ) as TotalCharges,				
		W.WireStateFee as WireStateFee, 
		W.WireTotalAmount,
		W.OriToDestExRate, W.DestAmount, W.DestCurrency,   
		W.TranTypeID, W.DeliveryType,
		W.BranchId, W.AgPayerId,
		W.DeptBankName, W.AccountNumber,
		W.DeptAdditionalInfo, W.PinNumber, 
		W.NoFaxBackWire, W.IncomingPhoneNumber, W.WireAvailableDate, 
		W.DiscountAmount, W.CRMPromotionID, W.WirePoints, W.WirePointsSign,
		isnull(w.CashBackAmount,0) CashBackAmount,
		w.SenderPaymentMethodId
	from Wires as W  
	inner join Senders as S on (S.LSenderId = W.LSenderId)
	inner join Receivers as R on (R.LReceiverId = W.LReceiverId)  	
	where W.WireId = @WireID
	
 