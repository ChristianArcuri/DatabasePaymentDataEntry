
CREATE PROCEDURE [dbo].[ImxDirect_WIRE_GetCenPosResult]
	@Username varchar(20), 
	@Pwd varchar(20), 
	@MID varchar(20),
	@WireTAG varchar(30)
AS
BEGIN
	DECLARE @Url varchar(255) = 'https://ww2.cenpos.net/6/1/transact.asmx'
	DECLARE @BeginDate datetime = dbo.DateOnly(GetDate()-1)
	DECLARE @EndDate datetime = dbo.DateOnly(GetDate())
	DECLARE @TransactionType varchar(20) = 'Sale'

SELECT	 IsSuccessful
		,AuthCode
		,TotalAmount
		,PaymentType
		,CardNumber
		,NameOnCard
		,ReferenceNumber
		,ResponseResult as ResultCode
		,ResponseMessage as ResultMessage
		FROM SqlCLR.dbo.CP_GetCardTransaction 
			  (@Url
			  ,@Username
			  ,@Pwd
			  ,@MID
			  ,@BeginDate 
			  ,@EndDate
			  ,@WireTAG 
			  ,@TransactionType)
		ORDER BY Created DESC
END