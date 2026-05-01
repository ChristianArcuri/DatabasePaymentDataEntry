
CREATE PROCEDURE BillPayment_PayverisPayee_Get
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
	@CurrentLanguageId int,
	@PayeeId bigint OUTPUT,
	@BusinessDaysToDeliver int OUTPUT,
	@NextAvailableProcessingDate datetime OUTPUT,
	@NextAvailableDeliveryDate datetime OUTPUT,
	@Result int OUTPUT, -- 0 Match, 1 SelectBillingAddress, 2 NoMatch or warning,  500 error 
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
	DECLARE @Addresses varchar(max)

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
	---- Only if BillerId > 0-------------------------------------------------------------

	IF ISNULL(@BillerId, 0) > 0
		BEGIN
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

            ---- Validate account number if payee doesn't exist---------------------------


            EXEC BillPayment_ValidateAccount
					@CurrentLanguageId,
					@BTPreparationId,
					@BillerId,
					@AccountNumber,
					@Result OUTPUT, -- 0 Match, 1 SelectBillingAddress, 2 NoMatch or warning,  500 error
					@ResultCode OUTPUT,
					@UserErrorMessage OUTPUT,
					@LogErrorMessage OUTPUT,
					@Addresses OUTPUT

			IF ISNULL(@Result, 0) > 1
  			  RETURN

            SET @Result = 0

		END

   ------------------Create payee ---------------------------------------

   DECLARE @Payees varchar(max)
   DECLARE @ValidationResult varchar(max)

   SELECT @IsSuccessful  = IsSuccessful,
	    @ResultCode = CASE WHEN IsSuccessful = 1 THEN '0' ELSE '1' END,
		@InfoMessage  = InfoMessage,
		@RequestData = RequestData,
		@ResponseData = ResponseData,
		@Payees = Payees,
		@ValidationResult = BillerValidationResults  
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

   DECLARE @handle INT  
   DECLARE @PrepareXmlStatus INT  
   DECLARE @xml xml

   IF ISNULL(@IsSuccessful, 0) = 0	
	BEGIN
		IF ISNULL(@ValidationResult, '') = ''	--AddPayee failed and doesn't return addresses
		BEGIN
			SET @LogErrorMessage = @InfoMessage
			SET @Result = 500
			SET @UserErrorMessage = 'An error ocurred creating the payee'  -- multilanguage?
			RETURN
		END

		SET @PayeeId = 0
		SET @BusinessDaysToDeliver = NULL
		SET @NextAvailableProcessingDate = NULL
		SET @NextAvailableDeliveryDate = NULL
		SET @Result = 1

		SET @xml = @ValidationResult

		IF @InfoMessage LIKE '%PAYEE_ALREADY_EXISTS%'
			BEGIN
			    DECLARE @TempBillerId int

				EXEC @PrepareXmlStatus= sp_xml_preparedocument @handle OUTPUT, @xml  

				SELECT  @TempBillerId = BillerId 
				FROM    OPENXML(@handle, '/ArrayOfBillerValidationResult/BillerValidationResult')  
					WITH (
					BillerId bigint 'BillerId',
					BillerDisplayName varchar(150) 'DisplayName',
					ValidationResult varchar(150) 'ValidationResult'
					) 
				WHERE ValidationResult = 'Match'

				EXEC sp_xml_removedocument @handle

				IF ISNULL(@TempBillerId, 0) > 0
				BEGIN
					SELECT @IsSuccessful  = IsSuccessful,
						@ResultCode = CASE WHEN IsSuccessful = 1 THEN '0' ELSE '500' END,
						@InfoMessage  = InfoMessage,
						@RequestData = RequestData,
						@ResponseData = ResponseData,
						@PayeeId = PayeeId,
						@BusinessDaysToDeliver = BusinessDaysToDeliver,
						@NextAvailableProcessingDate = NextAvailableProcessingDate,
						@NextAvailableDeliveryDate = NextAvailableDeliveryDate 
					FROM SqlCLR.dbo.BTPV_SearchPayee (@UserProfileId, @TempBillerId, 0, @AccountNumber)

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

					IF @IsSuccessful = 0 AND @InfoMessage LIKE '%Payee not found%'
					BEGIN
						SELECT @IsSuccessful  = IsSuccessful,
							@ResultCode = CASE WHEN IsSuccessful = 1 THEN '0' ELSE '500' END,
							@InfoMessage  = InfoMessage,
							@RequestData = RequestData,
							@ResponseData = ResponseData,
							@PayeeId = PayeeId,
							@BusinessDaysToDeliver = BusinessDaysToDeliver,
							@NextAvailableProcessingDate = NextAvailableProcessingDate,
							@NextAvailableDeliveryDate = NextAvailableDeliveryDate 
						FROM SqlCLR.dbo.BTPV_SearchPayee (@UserProfileId, @BillerId, 0, @AccountNumber)

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
					END

					IF ISNULL(@PayeeId, 0) > 0
					BEGIN
					  SET @BillerId = @TempBillerId
					  SET @Result = 0

  					  RETURN
					END
				END
			END
		ELSE
			BEGIN
				EXEC @PrepareXmlStatus= sp_xml_preparedocument @handle OUTPUT, @xml  

				SELECT *
				FROM    OPENXML(@handle, '/ArrayOfBillerValidationResult/BillerValidationResult/Addresses/Address')  
					WITH (
					BillerId bigint '../../BillerId',
					BillerDisplayName varchar(150) '../../DisplayName',
					AddressLine1 varchar(150) 'AddressLine1',
					City varchar(50) 'City',
					StateCode varchar(3) 'StateCode',
					ZipCode varchar(15) 'ZipCode',
					Country varchar(100) 'Country',
					BillerAddressId bigint 'AddressId'
					) 
			END
	END					
   ELSE  
	BEGIN
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
	END

	IF @handle IS NOT NULL
		EXEC sp_xml_removedocument @handle

END
