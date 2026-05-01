
CREATE PROCEDURE CardDirect_CenPosResult_GetAuthCode
	 @WireId int,
	 @AuthCode varchar(20) OUTPUT
as
BEGIN
  SET NOCOUNT ON;
  
  SELECT TOP 1 @AuthCode = r.AuthCode
  FROM Card_CenPosResults as r
	INNER JOIN WiresTAG as t on r.WireTAG = t.WireTAG
  WHERE t.Wireid = @WireId
	AND r.ResponseResult = 0
  ORDER BY r.ResultId desc

  IF @AuthCode IS NULL
	SET @AuthCode = ''
END