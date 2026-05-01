CREATE procedure [dbo].[CheckCENPOS_CardChargeStatus_SAVE]
  @Username varchar(20), @Pwd varchar(20), @MID varchar(20), @InvoiceNumber varchar(30)
as
  set nocount on;
-- BeginDate and EndDate are mandatory
  DECLARE @RecordId int = null

	DECLARE @Url varchar(255) = 'https://ww2.cenpos.net/6/1/transact.asmx'
	--DECLARE  @Username varchar(20) = 'admin'
	--DECLARE @Pwd varchar(20) = 'wB&8e9grD*5s'
	--DECLARE @MID varchar(20) = '400000222'
	DECLARE @BeginDate datetime = dbo.DateOnly(GetDate()-1)
	DECLARE @EndDate datetime = dbo.DateOnly(GetDate())
	--DECLARE @InvoiceNumber varchar(30) = 'IMX180130094204'
	DECLARE @TransactionType varchar(20) = 'Sale'  -- See transaction types on CenPOS Transaction API Guide.docx - page 13

  INSERT INTO Card_CenPosResults_WS with(rowlock) (IsSuccessful, InfoMessage, ResultCode,  ResultMessage, MerchantId, Username, Created, TranType,
	PaymentType, CardNumber, TotalAmount, AuthAmount, InvoiceNumber, ResponseResult, ResponseMessage,
	ReferenceNumber, AuthCode, IsSettled, SettleDate, NameOnCard, CardType, EntryMethod, CardExpirationDate,
	OriginalAmount, CardHostMerchantId, CardHostMerchantName, HostName, CustomerCode, EntryMode, TaxAmount)
		SELECT IsSuccessful, InfoMessage, ResultCode,  ResultMessage, MerchantId, Username, Created, TranType,
	PaymentType, CardNumber, TotalAmount, AuthAmount, InvoiceNumber, ResponseResult, ResponseMessage,
	ReferenceNumber, AuthCode, IsSettled, SettleDate, NameOnCard, CardType, EntryMethod, CardExpirationDate,
	OriginalAmount, CardHostMerchantId, CardHostMerchantName, HostName, CustomerCode, EntryMode, TaxAmount
		FROM SqlCLR.dbo.CP_GetCardTransaction 
			  (@Url
			  ,@Username
			  ,@Pwd
			  ,@MID
			  ,@BeginDate 
			  ,@EndDate
			  ,@InvoiceNumber 
			  ,@TransactionType)

 Set @RecordId = SCOPE_IDENTITY()

 select *
 from Card_CenPosResults_WS
 where ResultID = @RecordId
