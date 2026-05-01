
create PROCEDURE [dbo].[Card_CenPosResult_Get] 
	@WireTAG varchar(20)
AS
BEGIN

	SELECT ResultId 
        ,WireTAG
    	,AuthCode
		,Amount
		,Donation
		,OriginalAmount
		,CardType
		,CardNumber
		,IsCommercialCard
		,NameOnCard
		,Email
		,EntryMethod
		,ReferenceNumber
		,TraceNumber
		,ResponseResult
		,ResponseMessage
		,ProcessAs
		,SessionId
		,Token
		,Operation
		,[Signature]
		,Created
    FROM Card_CenPosResults WITH (NOLOCK)
	WHERE WireTAG = @WireTAG 

END
