CREATE procedure [dbo].[ProcessDebitCard_SQLCLR_OldJun06] 
     @WireId int,
     @AgencyCode varchar(20),
     @AgSenderSeq int,
     @CardNumber varchar(50), 
     @NameOnCard varchar(50), 
     @ExpirationDate varchar(4),
     @MagStripedata varchar(1024), --EncTrack2
     @PinData varchar(50), -- EPB
     @Amount numeric(18,2),
     @PinPadSerialNumber varchar(50), -- Pin pad KSN  remove leading F's
	 @MSRKeySerialNumber varchar(50), -- Card KSN
     @TransactionId varchar(20),
     @Result int output,
     @Msg varchar(1024) output,
     @CardChargeId int output,
	 @OutAuthCode varchar(50) output
as
    set nocount on; 
  
    DECLARE @LastCardDigits varchar(20)
	DECLARE @ServiceUrl varchar(255)
	DECLARE @ServiceUid varchar(50)
	DECLARE @ServicePwd varchar(50)
	DECLARE @TransType varchar(10) = 'Sale'
	DECLARE @PnRef varchar(100)
	DECLARE @SurchargeAmount numeric(18,2) = 0
	DECLARE @CashBackAmount numeric(18,2) = 0

	--Service configuration
		select @ServiceUrl = PayLeap_URL,
		       @ServiceUid = PayLeap_ApiLogin,
		       @ServicePwd = PayLeap_ApiKey
	from WireSecurity.dbo.PL_AgenciesConfig 
    where AgencyCode = @AgencyCode

	--SELECT @ServiceUrl = ParamValue FROM WireSecurity.dbo.ConfigParam WHERE ParamName = 'PayLeap_URL'
	--SELECT @ServiceUid = ParamValue FROM WireSecurity.dbo.ConfigParam WHERE ParamName = 'PayLeap_Username'
	--SELECT @ServicePwd = ParamValue FROM WireSecurity.dbo.ConfigParam WHERE ParamName = 'PayLeap_Password'

	--OUTPUT
	DECLARE @IsSuccessful bit--
	DECLARE @ErrorMsg varchar(max) --
	DECLARE @ResultCode varchar(10)--
	DECLARE @ResultMessage varchar(max)
	DECLARE @HostCode varchar(100) --
	DECLARE @AuthCode varchar(100)
	DECLARE @AvsResult varchar(10)
	DECLARE @IsCommercialCard bit
	DECLARE @PinPadSN varchar(100)
	DECLARE @CardType varchar(50)
	DECLARE @RequestData varchar(max)
    DECLARE @ResponseData varchar(max)

    SET @Msg = ''
    

	SELECT @CashBackAmount = ISNULL(CashBackAmount,0)
	  FROM Wires
	 WHERE WireId = @WireId

	
	--SALE
	SELECT @IsSuccessful = IsSuccessful --
		,@ErrorMsg = InfoMessage --
		,@ResultCode = ResultCode --
		,@ResultMessage = ResultMessage --
		,@HostCode = HostCode --
		,@PnRef = PnRef --
		,@AuthCode = AuthCode --
		,@AvsResult = AvsResult --
		,@IsCommercialCard = IsCommercialCard --
		,@PinPadSN = PinPadSerial --
		,@CardType = CardType
		,@RequestData = RequestData
		,@ResponseData = ResponseData
	FROM SQLCLR.dbo.PL_ProcessDebitCard(
		@ServiceUrl
	   ,@ServiceUid
	   ,@ServicePwd  
	   ,@TransType
	   ,@CardNumber
	   ,@NameOnCard
	   ,@ExpirationDate
	   ,@MagStripedata
	   ,@PinData
	   ,@PnRef 
	   ,@Amount
	   ,@SurchargeAmount
	   ,@CashBackAmount
	   ,@TransactionId
	   ,@PinPadSerialNumber
	   ,@MSRKeySerialNumber)
    
    Set @Result = 1 --Bad
	if @IsSuccessful = 1
	  begin
	    if IsNumeric(@ResultCode) = 1
	      Set @Result = Cast(@ResultCode as int)  -- When zero is Good
	  end

    if @Result = 0
	  Set @OutAuthCode = @AuthCode
    else
	  Set @OutAuthCode = ''


    SELECT @Msg = IsNull(@ResultMessage, ''), 
           @LastCardDigits = RIGHT(rtrim(@CardNumber), 4)
    
    INSERT INTO CardChargeResult with(rowlock)
           (WireId, AgencyCode, AgSenderSeq, LastCardDigits, NameOnCard, ExpDate,
            MagStripedata, PinData, TranAmount, PinPadSerialNumber, MSRKeySerialNumber, WireTAG,
            TranSuccessful, ResultCode, PnRef, AuthCode, ErrorMsg, 
            ResultMessage, HostCode, AvsResult, IsCommercialCard, CardType, 
			RequestData, ResponseData)
     VALUES
           (@WireId, @AgencyCode, @AgSenderSeq, @LastCardDigits, @NameOnCard, @ExpirationDate, 
            @MagStripedata, @PinData, @Amount, @PinPadSerialNumber, @MSRKeySerialNumber, @TransactionId,
            @IsSuccessful, @ResultCode, @PnRef, @AuthCode, @ErrorMsg, 
            @ResultMessage, @HostCode, @AvsResult, @IsCommercialCard, @CardType, 
			@RequestData, @ResponseData)
            
     SET @CardChargeId = SCOPE_IDENTITY();

	if @Result = 0 and rtrim(@ErrorMsg) = ''
	  update Wires with(rowlock) set CardChargeId = @CardChargeId
      where WireId = @WireId

     
	--SELECT @IsSuccessful AS IsSuccessful
	--		,@ErrorMsg AS ErrorMessage
	--		,@ResultCode AS ResultCode
	--		,@ResultMessage AS ResultMessage
	--		,@HostCode AS HostCode
	--		,@PNRef AS PnRef
	--		,@AuthCode AS AuthCode 
	--		,@AvsResult AS AvsResult 
	--		,@IsCommercialCard AS IsCommercialCard
	--		,@PinPadSN AS PinPadSerial 
	--		,@CardType AS CardType 



