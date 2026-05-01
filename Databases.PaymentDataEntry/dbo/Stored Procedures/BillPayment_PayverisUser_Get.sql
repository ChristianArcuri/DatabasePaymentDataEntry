
CREATE PROCEDURE [dbo].[BillPayment_PayverisUser_Get]
	@CurrentLanguageId int,
	@AgSendercode varchar(10),
	@AgPayerCode varchar(10),
	@SenderId int,
	@SndFirstName varchar(50),
	@SndLast1 varchar(50),
	@SndLast2 varchar(50),
	@SndAddress varchar(50),
	@SndCountry varchar(3),
	@SndState varchar(30),
	@SndCity varchar(40),
	@SndZip varchar(15),
	@BTPreparationId uniqueidentifier,
	@Result int OUTPUT, -- 0 OK, 500 error
	@UserErrorMessage varchar(300) OUTPUT,
	@LogErrorMessage varchar(MAX) OUTPUT,
	@UserProfileId varchar(50) OUTPUT
AS
BEGIN
    DECLARE @AccountNumber varchar(30) 
	DECLARE @RoutingNumber varchar(30)
	DECLARE @AccountType varchar(30) 
	DECLARE @IsSuccessful bit
	DECLARE @InfoMessage varchar(max)
	DECLARE @ResultCode varchar(10)
	DECLARE @ResultMessage varchar(max)
	DECLARE @RequestData varchar(max)
	DECLARE @ResponseData varchar(max)
	DECLARE @SndStateAbbr varchar(3)
	DECLARE @RequestDate datetime
    DECLARE @LogId bigint

	SET NOCOUNT ON;

    SELECT  @SndStateAbbr  = StateAbbr 
    FROM WireSearch.dbo.Geo_States 
    WHERE CountryAbbr = @SndCountry 
	  AND StateName = @SndState 

	SELECT @AccountNumber = b.AccountNumber,
		@RoutingNumber = b.RoutingNumber,
		@AccountType = b.AccountType 
	FROM WireSearch.dbo.BT_LegalEntity_BankAccounts b
		INNER JOIN Wiresearch.dbo.Agencies a ON b.LegalEntityCode = a.LegalEntityCode
	WHERE a.AgencyCode = @AgSendercode
		AND b.ProviderId = 1 -- Payveris (see table BT_Providers) 


    ---Call Payveris to create user profile if it doesn't exists or update it

	SET @UserProfileId = @AgSendercode + '_' + CONVERT(varchar,@SenderId)
	SET @RequestDate = GETDATE()

	SELECT  @IsSuccessful  = IsSuccessful,
	        @ResultCode = CASE WHEN IsSuccessful = 1 THEN '0' ELSE '500' END,
			@InfoMessage  = InfoMessage,
			@RequestData = RequestData,
			@ResponseData = ResponseData
	FROM SqlCLR.dbo.BTPV_GetUserProfile (@UserProfileId)

	EXECUTE SqlCLR.dbo.BTSG_ServiceLogs_Create
		'BTPV_GetUserProfile'
		,@RequestDate
		,@IsSuccessful
		,@InfoMessage
		,@ResultCode
		,@RequestData 
		,@ResponseData
		,0
		,@BTPreparationId
		,@LogId OUTPUT

	IF ISNULL(@IsSuccessful, 0) = 0 -- User doesn't  exist
	BEGIN
		SELECT @IsSuccessful  = IsSuccessful,
				@ResultCode = CASE WHEN IsSuccessful = 1 THEN '0' ELSE '500' END,
				@InfoMessage  = InfoMessage,
				@RequestData = RequestData,
				@ResponseData = ResponseData 
		FROM SqlCLR.dbo.BTPV_EnrollUser (@AgSendercode
										,@SenderId
										,@SndFirstName
										,@SndLast1
										,@SndAddress
										,@SndCity
										,@SndStateAbbr
										,@SndZip
										,@SndCountry
										,@AccountNumber
										,@RoutingNumber
										,@AccountType)

		SET @RequestDate = GETDATE()
		EXECUTE SqlCLR.dbo.BTSG_ServiceLogs_Create
				'BTPV_EnrollUser'
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
	ELSE
	BEGIN
		SELECT  @IsSuccessful  = IsSuccessful,
				@ResultCode = CASE WHEN IsSuccessful = 1 THEN '0' ELSE '500' END,
				@InfoMessage  = InfoMessage,
				@RequestData = RequestData,
				@ResponseData = ResponseData 
		FROM SqlCLR.dbo.BTPV_UpdateUserProfile ( @AgSendercode
												,@SenderId
												,@SndFirstName
												,@SndLast1
												,@SndAddress
												,@SndCity
												,@SndStateAbbr
												,@SndZip
												,@SndCountry
												,@AccountNumber
												,@RoutingNumber
												,@AccountType)

											  

		SET @RequestDate = GETDATE()
		EXECUTE SqlCLR.dbo.BTSG_ServiceLogs_Create
				'BTPV_UpdateUserProfile'
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

	SET @Result = 0

	IF ISNULL(@IsSuccessful , 0)= 0
      BEGIN
	     SET @LogErrorMessage = @InfoMessage
		 SET @Result = 500
		 SET @UserErrorMessage = 'An error ocurred creating the user profile'  -- multilanguage?
		 SET @UserProfileId = NULL
	  END
END
