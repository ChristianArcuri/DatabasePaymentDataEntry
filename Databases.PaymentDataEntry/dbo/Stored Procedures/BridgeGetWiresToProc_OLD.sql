CREATE procedure [dbo].[BridgeGetWiresToProc_OLD]
as
  set nocount on;
  
    SELECT --top 1 
           W.WireId
		  ,W.LSenderId, W.LReceiverId, W.AgSenderId, W.AgSenderCode, W.AgSenderSeq, W.AgSenderState, W.AgSenderCity, W.AgSenderCountry
		  ,W.AgPayerId, W.AgPayerCode, W.DestCountry, W.DestState, W.DestCity, W.BranchId, W.SenderId, W.OnBehalfId, W.ReceiverId
		  ,W.SenderName, W.OnBehalfName, W.ReceiverName, W.PinNumber, W.WireDate, W.WireDatetime, W.OriAmount, W.OriCurrency
		  ,W.Charges, W.OtherChg, W.AgencyFee, W.OriToDestExRate, W.WireStateFee, W.WireTotalAmount, W.DestAmount, W.DestCurrency
		  ,W.AgSenderCommission, W.TranTypeID, W.AccountNumber, W.DeptBankName, W.AccountType, W.DeptAdditionalInfo, W.BankBranchCode
		  ,W.DeliveryType, W.SourceApp, W.StsComplianceOk, W.StsCancel, W.CustTrasactionID, W.RateTypeID, W.FeePlanID, W.FxPlanID
		  ,W.AgCommiPlanID, W.FXDif, W.FXShare_id, W.ExRateMacro, W.WirePurpose, W.FundSource, W.Occupation, W.IncomingPhoneNumber
		  ,W.CallerIDVerif, W.TeledirectWire, W.NoFaxBackWire, W.ReplacedControl, W.WaivedCharges, W.ReplaceWireRcvSel, W.CustMessage
		  ,W.WireReplacementType, W.ReplacementReasonID, W.MemberCardSwiped, W.SndDOB, W.CreatedBy, W.ComputerName, W.PayerPayMethodId
		  ,W.SndRcvRelationship, W.NewTelewire, W.FxPointsAdded, W.FXChangeCost, W.FXCostApplyTo
		  ,S.SenderGroupId, S.SndFirstName, S.SndLast1, S.SndLast2, S.SndAddress, S.SndCountry, S.SndState, S.SndCity, S.SndZip
		  ,S.SndPhone, S.SndLastVersionId, S.SndNoSecLastName
 		  ,R.ReceiverGroupId, R.RcvFirstName, R.RcvLast1, R.RcvLast2, R.RcvAddress, R.RcvCountry, R.RcvState, R.RcvCity, R.RcvZip
		  ,R.RcvPhone, R.RcvNoSecLastName, R.RcvLastVersionID, R.CPF
      FROM Wires as W
           INNER JOIN ProcessedWires as P on (W.WireId = P.WireId)
           INNER JOIN Senders as S         on (W.LSenderId = S.LSenderId)
           INNER JOIN Receivers as R       on (W.LReceiverId = R.LReceiverId)
       WHERE Done =0
      ORDER BY W.WireId
      