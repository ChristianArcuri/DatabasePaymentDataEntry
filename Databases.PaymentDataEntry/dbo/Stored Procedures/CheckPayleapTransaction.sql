CREATE procedure [dbo].[CheckPayleapTransaction]
   @WireId int,
   @AgencyCode varchar(20),
   @AgSenderSeq int,
   @TransactionId varchar(20),
   @Result int output,
   @Msg varchar(1024) output,
   @CardChargeId int output,
   @OutAuthCode varchar(50) output
as
  set nocount on;

  DECLARE @IsSuccessful bit = 0,                 
	      @InfoMessage nvarchar(max),        
	      @ResultCode nvarchar(10),          
	      @ResultMessage nvarchar(max),      
	      @AuthCode nvarchar(100),           
	      @CardHash nvarchar(100),           
	      @CardType nvarchar(50),            
	      @ExpDate nvarchar(10),             
	      @GetAVSResult nvarchar(100),       
	      @GetCVResult nvarchar(100),        
	      @HostCode nvarchar(50),            
	      @InvoiceNumber nvarchar(50),       
	      @LastFourOfCard nvarchar(10),      
	      @PNRef nvarchar(50),               
	      @ProcessedAs nvarchar(50),         
	      @Status nvarchar(50),              
	      @RequestData nvarchar(max),        
	      @ResponseData nvarchar(max)        

  DECLARE @ServiceUrl varchar(255)
  DECLARE @ServiceUid varchar(50)
  DECLARE @ServicePwd varchar(50)

	--Service configuration
  select @ServiceUrl = PayLeap_URL,
	     @ServiceUid = PayLeap_ApiLogin,
	     @ServicePwd = PayLeap_ApiKey
  from WireSecurity.dbo.PL_AgenciesConfig 
  where AgencyCode = @AgencyCode

  SET @Msg = ''

  SELECT  @IsSuccessful = IsSuccessful,
          @InfoMessage = InfoMessage,
          @ResultCode = ResultCode,
          @ResultMessage = ResultMessage,
          @AuthCode = AuthCode,
          @CardHash = CardHash,
          @CardType = CardType,
          @ExpDate = ExpDate,
          @GetAVSResult = GetAVSResult,
          @GetCVResult = GetCVResult,
          @HostCode = HostCode,
          @InvoiceNumber = InvoiceNumber,
          @LastFourOfCard = LastFourOfCard,
          @PNRef = PNRef,
          @ProcessedAs = ProcessedAs,
          @Status = [Status],
          @RequestData = RequestData,
          @ResponseData = ResponseData
FROM SQLCLR.dbo.PL_GetCardTransaction (@ServiceUrl,
                                       @ServiceUid,
                                       @ServicePwd,
									   '', --@OrderId
                                       @TransactionId)

    Set @Result = 1 --Bad
	if @IsSuccessful = 1
	  begin
	  
	    if @Status = 'approved'
		   begin
		     Set @Result = 0
			 set @ResultMessage = 'Approved'
			 set @InfoMessage   = 'APPROVAL'
		   end
	  else begin
		     Set @Result = -100
		     set @ResultMessage = 'Fail'
			 set @InfoMessage   = 'Failed'
		   end  
	     
	  end

   if @Result = 0
     Set @OutAuthCode = @AuthCode
   else
     Set @OutAuthCode = ''

    SELECT @Msg = IsNull(@ResultMessage, '')

    INSERT INTO CardChargeResult with(rowlock)
           (WireId, AgencyCode, AgSenderSeq, WireTAG,
		    LastCardDigits, ExpDate, CardType,
            TranSuccessful, ResultCode, PnRef, AuthCode,
            ResultMessage, HostCode, AvsResult, 
			ErrorMsg, 
			RequestData, ResponseData)
     VALUES
           (@WireId, @AgencyCode, @AgSenderSeq, @TransactionId,
		    @LastFourOfCard, @ExpDate, @CardType,
            @IsSuccessful, @ResultCode, @PnRef, @AuthCode,
            @ResultMessage, @HostCode, @GetAVSResult, 
			@InfoMessage, 
			@RequestData, @ResponseData)
            
     SET @CardChargeId = SCOPE_IDENTITY();

	if @Result = 0 and rtrim(@InfoMessage) = '' 
	  update Wires with(rowlock) set CardChargeId = @CardChargeId
      where WireId = @WireId
