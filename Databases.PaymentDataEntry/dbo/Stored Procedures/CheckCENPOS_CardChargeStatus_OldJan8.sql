CREATE procedure [dbo].[CheckCENPOS_CardChargeStatus_OldJan8]
  @Username varchar(20), @Pwd varchar(20), @MID varchar(20), @InvoiceNumber varchar(30)
as
  set nocount on;
-- BeginDate and EndDate are mandatory

declare @CardCenPosResults_WS TABLE (
	IsSuccessful bit, InfoMessage varchar(max), ResultCode int, ResultMessage varchar(max), MerchantId int, Username varchar(50), 
	Created datetime, TranType varchar(20), PaymentType varchar(20), CardNumber varchar(16), TotalAmount decimal(18, 2), 
	AuthAmount decimal(18, 2), InvoiceNumber varchar(50), ResponseResult int, ResponseMessage varchar(max), ReferenceNumber bigint, 
	AuthCode varchar(20), IsSettled bit, SettleDate datetime, NameOnCard varchar(100), CardType varchar(50), EntryMethod varchar(30), 
	CardExpirationDate varchar(10), OriginalAmount decimal(18, 2), CardHostMerchantId varchar(20), CardHostMerchantName varchar(100), 
	HostName varchar(100), CustomerCode varchar(50), EntryMode varchar(20), TaxAmount decimal(18, 2)
   )

  DECLARE @RecordId int = null

	DECLARE @Url varchar(255) = 'https://ww2.cenpos.net/6/1/transact.asmx'
	--DECLARE  @Username varchar(20) = 'admin'
	--DECLARE @Pwd varchar(20) = 'wB&8e9grD*5s'
	--DECLARE @MID varchar(20) = '400000222'
	DECLARE @BeginDate datetime = dbo.DateOnly(GetDate()-1)
	DECLARE @EndDate datetime = dbo.DateOnly(GetDate())
	--DECLARE @InvoiceNumber varchar(30) = 'IMX180130094204'
	DECLARE @TransactionType varchar(20) = 'Sale'  -- See transaction types on CenPOS Transaction API Guide.docx - page 13
	DECLARE @ResponseResult INT, @ReferenceNumber BIGINT, @MerchantId INT, @NameOnCard VARCHAR(100), 
	        @CustomerCode VARCHAR(50), @CardExpirationDate VARCHAR(10), @AuthCode varchar(20)

    INSERT INTO @CardCenPosResults_WS(
    IsSuccessful, InfoMessage, ResultCode,  ResultMessage, MerchantId, Username, 
	Created, TranType, PaymentType, CardNumber, TotalAmount, 
	AuthAmount, InvoiceNumber, ResponseResult, ResponseMessage, ReferenceNumber, 
	AuthCode, IsSettled, SettleDate, NameOnCard, CardType, EntryMethod, 
	CardExpirationDate, OriginalAmount, CardHostMerchantId, CardHostMerchantName, 
    HostName, CustomerCode, EntryMode, TaxAmount)
		SELECT IsSuccessful, InfoMessage, ResultCode,  ResultMessage, MerchantId, Username, 
		       Created, TranType, PaymentType, CardNumber, TotalAmount, 
			   AuthAmount, InvoiceNumber, ResponseResult, ResponseMessage, ReferenceNumber, 
			   AuthCode, IsSettled, SettleDate, NameOnCard, CardType, EntryMethod, 
			   CardExpirationDate, OriginalAmount, CardHostMerchantId, CardHostMerchantName, 
			   HostName, CustomerCode, EntryMode, TaxAmount
		FROM SqlCLR.dbo.CP_GetCardTransaction 
			  (@Url
			  ,@Username
			  ,@Pwd
			  ,@MID
			  ,@BeginDate 
			  ,@EndDate
			  ,@InvoiceNumber 
			  ,@TransactionType)

 
   SELECT TOP 1 @ResponseResult = ResponseResult, @ReferenceNumber = ReferenceNumber, @MerchantId = MerchantId, 
                @NameOnCard = NameOnCard, @CustomerCode = CustomerCode, @CardExpirationDate = CardExpirationDate, 
				@AuthCode = AuthCode 
   FROM @CardCenPosResults_WS
   ORDER BY Created desc

   SELECT @RecordId = ResultID 
   FROM Card_CenPosResults_WS 
   WHERE InvoiceNumber = @InvoiceNumber AND ResponseResult = @ResponseResult AND ReferenceNumber = @ReferenceNumber AND
		 MerchantId = @MerchantId and NameOnCard = @NameOnCard and CustomerCode = @CustomerCode and 
		 CardExpirationDate = @CardExpirationDate

   
   IF @RecordId is null
     begin
		INSERT INTO Card_CenPosResults_WS with(rowlock) (
		 IsSuccessful, InfoMessage, ResultCode,  ResultMessage, MerchantId, Username, 
		 Created, TranType, PaymentType, CardNumber, TotalAmount, 
		 AuthAmount, InvoiceNumber, ResponseResult, ResponseMessage, ReferenceNumber, 
		 AuthCode, IsSettled, SettleDate, NameOnCard, CardType, EntryMethod, 
		 CardExpirationDate, OriginalAmount, CardHostMerchantId, CardHostMerchantName, 
		 HostName, CustomerCode, EntryMode, TaxAmount)
			SELECT TOP 1 IsSuccessful, InfoMessage, ResultCode,  ResultMessage, MerchantId, Username, 
				   Created, TranType, PaymentType, CardNumber, TotalAmount, 
				   AuthAmount, InvoiceNumber, ResponseResult, ResponseMessage, ReferenceNumber, 
				   AuthCode, IsSettled, SettleDate, NameOnCard, CardType, EntryMethod, 
				   CardExpirationDate, OriginalAmount, CardHostMerchantId, CardHostMerchantName, 
				   HostName, CustomerCode, EntryMode, TaxAmount
			FROM @CardCenPosResults_WS
			ORDER BY Created desc

		 Set @RecordId = SCOPE_IDENTITY()
	 end

 select *
 from Card_CenPosResults_WS
 where ResultID = @RecordId
