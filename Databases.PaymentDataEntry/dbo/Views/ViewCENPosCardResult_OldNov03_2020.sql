
CREATE VIEW [dbo].[ViewCENPosCardResult_OldNov03_2020] AS
	SELECT T1.WireID, T1.WireTAG, T2.ResultId, T2.CardType, T2.CardNumber, T2.NameOnCard, T2.ReferenceNumber, T2.AuthCode, T2.ResponseResult, T2.ResponseMessage
	FROM WiresTAG T1
	  JOIN Card_CenPosResults T2 ON T1.WireTAG = T2.WireTAG
