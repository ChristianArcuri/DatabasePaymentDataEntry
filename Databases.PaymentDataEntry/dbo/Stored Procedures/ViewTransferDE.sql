CREATE procedure [dbo].[ViewTransferDE] @WireId int
as
  set nocount on;
    
select --TOP 100 *,
       T1.AgSenderCode, T1.AgSenderId, T9.AgState, T9.AgCity, T9.AgCountry as AgSndCountry, T9.AgName, T9.AgPhone1, T9.AgAddress, T9.AgZip,
       T1.SenderId, T2.SndFullName, T2.SndFirstName, T2.SndLast1, T2.SndLast2, 
       T2.SndAddress, T2.SndCity, T2.SndState, T2.SndZip, T2.SndPhone, T2.SndCountry, T2.SenderGroupId,
       T3.Receiverid as ReceiverId, T1.ReceiverName, T3.RcvFirstName, T3.RcvLast1, T3.RcvLast2, T3.RcvAddress, T3.RcvCountry, RcvState, RcvCity, RcvZip, RcvPhone,
       (case when T1.TranTypeID = 4 then 'Wire Transfer' else T4.TransactionTypeName end)as TransactionTypeName,
       T5.BrCity, T5.BrState, T5.BrName, T6.AgName as PayerInstName, T6.AgencyId as AgPayerID,             
       DeptBankName, AccountNumber, DeptAdditionalInfo,BankBranchCode, AccountType as BankAccType,
       OriAmount, Charges, AgencyFee, WireStateFee, RateTypeId, 
       WireTotalAmount, OriToDestExRate, DestAmount, DiscountAmount,
       T1.AgSenderSeq, WireDateTime, 
       DestCurrency,
       OriCurrency, 
       DeliveryTypeDesc as DelMtd, 
       cast((case when T1.TranTypeID = 4 then 'MO' else 'CASH' end) as varchar(5)) as PayMtd,
       WireSearch.dbo.fn_GetCurrencyName(WireSearch.dbo.fn_Get_ISO_Currency(T1.DestCurrency, T5.BrCountry)) as CurrName,
       T1.CreatedBy, T3.CPF, T1.TranTypeID, AgPayerCode, 
       T1.BranchId, T5.BrPlaceName, T5.BrAddress, PinNumber, T1.DeliveryType, 
       StsCancel, WirePurpose, FundSource, T1.Occupation, SndRcvRelationShip, T1.CustMessage as [Message],
       WireAvailableDate, WireReplacementType, TeledirectWire, T9.PayerOnWireRcpForDep,
       T5.MonFriHours as WeeklyHours, T5.SatHours as SaturdayHours, T5.SunHours as SundayHours,
       T9.AgShortName, T9.AcceptNoFaxBack, T5.BrName as BranchName, T1.OtherChg, T10.DOB as SndDOB, T10.SameSenderId 
from Wires T1
  join Senders T2 ON T1.LSenderId = T2.LSenderId
  join Receivers T3 ON T1.LReceiverId = T3.LReceiverId
  join WireSearch.dbo.TransactionTypes T4 ON T1.TranTypeID = T4.TranTypeID
  left outer join WireSearch.dbo.Branches T5 ON T1.Branchid = T5.BranchID
  left outer join WireSearch.dbo.Agencies T6 ON T5.AgencyID = T6.AgencyID
  left outer join WireSearch.dbo.ViewDeliveryTypes T7 ON T7.DeliveryType = T1.DeliveryType
  left outer join WireSearch.dbo.Agencies T9 ON T9.AgencyId = T1.AgSenderId
  left outer join WireSearch.dbo.Senders T10 ON T10.SenderId = T1.SenderId
--  left outer join WireCompInfo T10 ON T10.Control = T1.Control
where T1.WireId = @WireId




