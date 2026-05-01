
CREATE View [dbo].[ViewCENPosCardResult] as
	select T1.WireID, T1.WireTAG, T2.ResultId, T2.CardType, T2.CardNumber, T2.NameOnCard, T2.ReferenceNumber, T2.AuthCode, T2.ResponseResult, T2.ResponseMessage
	from WiresTAG T1 WITH(nolock)
	  join Card_CenPosResults as T2 WITH(nolock)  on T1.WireTAG = T2.WireTAG

