
CREATE PROCEDURE dbo.BillPayment_ValidateAccount
	@CurrentLanguageId int,
	@BTPreparationId uniqueidentifier,
	@BillerId bigint,
	@AccountNumber varchar(20),
	@ValidResult int OUTPUT, -- 0 Match, 1 SelectBillingAddress, 2 NoMatch or warning,  500 error
	@ErrorCode varchar(10) OUTPUT,
	@UserErrorMessage varchar(300) OUTPUT,
	@LogErrorMessage varchar(MAX) OUTPUT,
	@Addresses varchar(max) OUTPUT
AS
BEGIN
  --------------------------------------------------------------- 
  -------------DECLARE OUTPUT------------------------------------
  ---------------------------------------------------------------
	DECLARE @IsSuccessful bit
	DECLARE @InfoMessage varchar(max)
	DECLARE @ValidationResult varchar(20)
	DECLARE @DisplayName varchar(100)
	DECLARE @RequestData varchar(max)
	DECLARE @ResponseData varchar(max)
	
  --------------------------------------------------------------- 
  -------------VALIDATE INTPUT-----------------------------------
  ---------------------------------------------------------------
    IF ISNULL(@BillerId, 0) <= 0
	   BEGIN
	     SET @ValidResult = 2
		 SET @ErrorCode = 11058 --Please select the Service to pay
		 SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	     SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
		 RETURN
	   END

    IF rtrim(@AccountNumber) = ''
	   BEGIN
	     SET @ValidResult = 2
		 SET @ErrorCode = 11059 --Please provide the Account Number
		 SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	     SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
		 RETURN
	   END


  --------------------------------------------------------------- 
  -------------CALL EXTERNAL PROVIDER----------------------------
  ---------------------------------------------------------------

	SELECT  @IsSuccessful		 = IsSuccessful,
			@InfoMessage		 = InfoMessage,
			@ValidationResult    = ValidationResult,
			@DisplayName		 = DisplayName,
			@Addresses			 = Addresses,
			@RequestData		 = RequestData,
			@ResponseData		 = ResponseData
	FROM SqlCLR.dbo.BTPV_ValidateBillerAccount (@BillerId, @AccountNumber)


  --------------------------------------------------------------- 
  ---------------------LOGGING-----------------------------------
  ---------------------------------------------------------------

	DECLARE @RequestDate datetime = GETDATE()
	DECLARE @LogId bigint

	EXECUTE SqlCLR.dbo.BTSG_ServiceLogs_Create   'BillPaymentVerification'
												  ,@RequestDate
												  ,@IsSuccessful
												  ,@InfoMessage
												  ,@ValidationResult
												  ,@RequestData 
												  ,@ResponseData
												  ,0
												  ,@BTPreparationId
												  ,@LogId OUTPUT

  --------------------------------------------------------------- 
  -----------------SETTING RESULTS-------------------------------
  ---------------------------------------------------------------

	IF  @IsSuccessful = 0
	    BEGIN
		  SET @ValidResult      = 500 --Error
		  SET @LogErrorMessage  = @InfoMessage
		  SET @UserErrorMessage = @InfoMessage
		  RETURN
		END
    

	IF ISNULL(@ValidationResult, '') = 'NoMatch' 
		BEGIN
			SET @ValidResult      = 2 --NotMatch or warning
			SET @ErrorCode		  = 1159 --Invalid account number.
			SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	        SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
			RETURN
		END
	ELSE IF ISNULL(@ValidationResult, '') = 'SelectBillingAddress'
		BEGIN
	        SET @ValidResult      = 1 --SelectBillingAddress
			SET @ErrorCode		  = 11312 --Please select the billing address
			SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	        SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
			RETURN
		END

	ELSE IF ISNULL(@ValidationResult, '') = 'Match' 
	        BEGIN
	          SET @ValidResult      = 0 --OK
		      SET @LogErrorMessage  = ''
		      SET @UserErrorMessage = ''
		      RETURN
	       END
   ELSE BEGIN
            SET @ValidResult      = 500
			SET @LogErrorMessage  = @InfoMessage
			SET @UserErrorMessage = @InfoMessage
			RETURN
        END 

END