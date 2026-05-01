
CREATE PROCEDURE [dbo].[BillPayment_PayverisPayee_Get_OldOct31_2019] 
	@UserProfileId varchar(50),
	@BTPreparationId uniqueidentifier,
	@BillerId int,
	@BillerGroupId int,
	@BillerName varchar(150),
	@AccountNumber varchar(30),
	@BillingAddress varchar(50),
	@BillingCountry varchar(3),
	@BillingStateAbbr varchar(3),
	@BillingCity varchar(40),
	@BillingZip varchar(15),
	@PayeeId bigint OUTPUT,
	@BusinessDaysToDeliver int OUTPUT,
	@NextAvailableProcessingDate datetime OUTPUT,
	@NextAvailableDeliveryDate datetime OUTPUT,
	@Result int OUTPUT, -- 0 OK, 500 error
	@UserErrorMessage varchar(300) OUTPUT,
	@LogErrorMessage varchar(MAX) OUTPUT
AS
BEGIN

	DECLARE @IsSuccessful bit
	DECLARE @InfoMessage varchar(max)
	DECLARE @ResultCode varchar(10)
	DECLARE @ResultMessage varchar(max)
	DECLARE @RequestData varchar(max)
	DECLARE @ResponseData varchar(max)
	DECLARE @RequestDate datetime
    DECLARE @LogId bigint
	DECLARE @PvAccountNumber varchar(30)
	DECLARE @PvBillerId bigint
	DECLARE @FinalBillerId bigint

	SET NOCOUNT ON;

	SET @Result = 0

	----Get payee if PayeeId is provided--------------------------
	IF ISNULL(@PayeeId, 0) > 0
		BEGIN
			SELECT @IsSuccessful  = IsSuccessful,
			    @ResultCode = CASE WHEN IsSuccessful = 1 THEN '0' ELSE '500' END,
				@InfoMessage  = InfoMessage,
				@RequestData = RequestData,
				@ResponseData = ResponseData,
			    @PvAccountNumber = @AccountNumber,
				@PvBillerId = BillerId,
				@BusinessDaysToDeliver = BusinessDaysToDeliver,
			    @NextAvailableProcessingDate = NextAvailableProcessingDate,
			    @NextAvailableDeliveryDate = NextAvailableDeliveryDate
			FROM SqlCLR.dbo.BTPV_GetPayee (@UserProfileId, @PayeeId)

			SET @RequestDate = GETDATE()
			EXECUTE SqlCLR.dbo.BTSG_ServiceLogs_Create
						'BTPV_GetPayee'
						,@RequestDate
						,@IsSuccessful
						,@InfoMessage
						,@ResultCode
						,@RequestData 
						,@ResponseData
						,0
						,@BTPreparationId
						,@LogId OUTPUT

			IF (@AccountNumber = @PvAccountNumber) AND (ISNULL(@BillerId, 0) = 0 OR @BillerId = @PvBillerId)
				RETURN
		END

    ---- Search payee if exists by account number and biller id---------------------------
	SET @PayeeId = 0

    SELECT @IsSuccessful  = IsSuccessful,
	    @ResultCode = CASE WHEN IsSuccessful = 1 THEN '0' ELSE '500' END,
		@InfoMessage  = InfoMessage,
		@RequestData = RequestData,
		@ResponseData = ResponseData,
		@PayeeId = PayeeId,
		@BusinessDaysToDeliver = BusinessDaysToDeliver,
		@NextAvailableProcessingDate = NextAvailableProcessingDate,
		@NextAvailableDeliveryDate = NextAvailableDeliveryDate 
	FROM SqlCLR.dbo.BTPV_SearchPayee (@UserProfileId, @BillerId, @BillerGroupId, @AccountNumber)

	SET @RequestDate = GETDATE()
	EXECUTE SqlCLR.dbo.BTSG_ServiceLogs_Create
				'BTPV_SearchPayee'
				,@RequestDate
				,@IsSuccessful
				,@InfoMessage
				,@ResultCode
				,@RequestData 
				,@ResponseData
				,0
				,@BTPreparationId
				,@LogId OUTPUT

    IF ISNULL(@PayeeId, 0) > 0
  	  RETURN

   ------------------Create payee ---------------------------------------

   DECLARE @Payees varchar(max)

   SELECT @IsSuccessful  = IsSuccessful,
	    @ResultCode = CASE WHEN IsSuccessful = 1 THEN '0' ELSE '500' END,
		@InfoMessage  = InfoMessage,
		@RequestData = RequestData,
		@ResponseData = ResponseData,
		@Payees = Payees  
	FROM SqlCLR.dbo.BTPV_AddPayee (@UserProfileId
								  ,@BillerName
								  ,@UserProfileId + '-' + CONVERT(varchar,@BillerGroupId) + '-' + CONVERT(varchar,@BillerId)
								  ,@BillerId
								  ,@BillerGroupId
								  ,@AccountNumber
								  ,@BillingAddress
								  ,@BillingCity
								  ,@BillingStateAbbr
								  ,@BillingZip
								  ,@BillingCountry)

   SET @RequestDate = GETDATE()
   EXECUTE SqlCLR.dbo.BTSG_ServiceLogs_Create
				'BTPV_AddPayee'
				,@RequestDate
				,@IsSuccessful
				,@InfoMessage
				,@ResultCode
				,@RequestData 
				,@ResponseData
				,0
				,@BTPreparationId
				,@LogId OUTPUT

   IF ISNULL(@IsSuccessful, 0) = 0
	BEGIN
		SET @LogErrorMessage = @InfoMessage
		SET @Result = 500
		SET @UserErrorMessage = 'An error ocurred creating the payee'  -- multilanguage?
		RETURN
	END

	DECLARE @handle INT  
	DECLARE @PrepareXmlStatus INT  
	DECLARE @xml xml

	SET @xml = @Payees

	EXEC @PrepareXmlStatus= sp_xml_preparedocument @handle OUTPUT, @xml  

	SELECT  @PayeeId = PayeeId,
	        @BusinessDaysToDeliver = BusinessDaysToDeliver,
			@NextAvailableProcessingDate = NextAvailableProcessingDate,
			@NextAvailableDeliveryDate = NextAvailableDeliveryDate
	FROM    OPENXML(@handle, '/ArrayOfPayee/Payee', 2)  
		WITH (
				PayeeId bigint,
				DisplayName varchar(150),
				BillerId bigint,
				BusinessDaysToDeliver INT,
				CanExpeditePayments bit,
				Nickname varchar(30),
				PaymentAccount varchar(50),
				PaymentAccountMask varchar(50),
				[Status] varchar(30),
				NextAvailableProcessingDate datetime,
				NextAvailableDeliveryDate datetime,
				PaymentMethod varchar(30),
				AddressId bigint 'BillingAddress/AddressId',
				AddressLine1 varchar(150) 'BillingAddress/AddressLine1',
				City varchar(50) 'BillingAddress/City',
				StateCode varchar(3) 'BillingAddress/StateCode',
				ZipCode varchar(15) 'BillingAddress/ZipCode',
				Country varchar(100) 'BillingAddress/Country'
			)  


	EXEC sp_xml_removedocument @handle

END
