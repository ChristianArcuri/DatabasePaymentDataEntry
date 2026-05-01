CREATE procedure [dbo].[BridgeGetWiresToProc_WebAgent_fase3_1]
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
		  ,W.SndRcvRelationship, W.NewTelewire, W.FxPointsAdded, W.FXChangeCost, W.FXCostApplyTo, W.FeeChange, W.CostToAgent, W.CostToCustomer
		  ,W.FlexPrcOptionSelected
		  ,S.SenderGroupId, S.SndFirstName, S.SndLast1, S.SndLast2, S.SndAddress, S.SndCountry, S.SndState, S.SndCity, S.SndZip
		  ,S.SndPhone, S.SndLastVersionId, S.SndNoSecLastName
 		  ,ISNULL(S.SndIdTypeName,'') as SndIdTypeName , ISNULL(S.SndIdNumber,'') as SndIdNumber , ISNULL(S.SndIdCountry,'') as SndIdCountry
 		  ,ISNULL(S.SndIdState,'') as SndIdState, SndIdExpirationDate 
 		  ,R.ReceiverGroupId, R.RcvFirstName, R.RcvLast1, R.RcvLast2, R.RcvAddress, R.RcvCountry, R.RcvState, R.RcvCity, R.RcvZip
		  ,R.RcvPhone, R.RcvNoSecLastName, R.RcvLastVersionID, R.CPF, W.PossibleFraud, W.WireAvailableDate
		  ,S.SndEmail, S.IsCellPhone, DiscountAmount, PromoCostToCompany, PromoCostToAgent, PromoCostToPayer, CRMPromotionID as PromotionId, SenderPromoUniqueKey
          ,WirePoints, WirePointsSign, WiresAlreadyCountGUID, W.LoyaltyCardNumber, OptStatus, OptStatusDate
          ,W.SenderPaymentMethodId, W.WireReadyToChargeSender, W.WebAgentUserId, W.UserPaymentMethodInfoId, W.WireIPAddress
          ,W.WireFromState, W.IPDetectedState, W.WebAgentTransationId, W.StsSenderPaymentOk 
          ,CollectionType,StsFraudCheckOk,CancelReasonId,
		  ISNULL(FraudCheckTransacId,'') as FraudCheckTransacId,ISNULL(FraudCheckDecision,'') as FraudCheckDecision,
		  ISNULL(FraudCheckDecisionReason,'') as FraudCheckDecisionReason,ISNULL(FraudCheckScore,0) as FraudCheckScore,FraudCheckDate ,
		  w.StsUserKBAOk,w.StsCreditOK
      FROM Wires as W with(nolock) 
           INNER JOIN ProcessedWires as P  with(nolock) on (W.WireId = P.WireId)
           INNER JOIN Senders as S  with(nolock) on (W.LSenderId = S.LSenderId)
           INNER JOIN Receivers as R with(nolock) on (W.LReceiverId = R.LReceiverId)
		   LEFT OUTER JOIN WebAgent_WireFraudCheck as f on W.WireId = F.WireId
       WHERE Done=0 
           and not Exists(select * from dbo.WirePossibleFraud T01 with(nolock) where T01.WireId = W.WireId and (Ok is null or Ok = 0))
      ORDER BY W.WireId
      