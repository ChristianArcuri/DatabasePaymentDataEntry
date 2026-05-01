CREATE PROCEDURE [dbo].[WebAgent_SaveInPreparation_IPDetectedState_oldSep11]
@PreparationId uniqueidentifier,
@CurrentWebLanguageId int,
@IpAddress varchar(50),
@IPDetectedState varchar(40) OUTPUT,
@ValidResult int OUTPUT,
@ErrorCode varchar(10) OUTPUT,
@UserErrorMessage varchar(300) OUTPUT,
@LogErrorMessage varchar(MAX) OUTPUT
AS
BEGIN
   DECLARE @IsSuccesful bit
   DECLARE @CountryCode varchar(2)
   DECLARE @ErrorMessage varchar(4000)
   DECLARE @StateCode varchar(2)
   SET @ErrorCode = ''
   SET @UserErrorMessage = ''
   SET @LogErrorMessage = ''

   	   

   Select @IPDetectedState = IPDetectedState 
     FROM WebAgent_WireInPreparation
    Where PreparationId = @PreparationId
	  and WireIPAddress = @IpAddress
	  and (IPDetectedState IS NOT NULL AND IPDetectedState <> '')
	IF @@ROWCOUNT = 1
	   BEGIN
	     SET @ValidResult = 0
		 RETURN
       END


  --SELECT * from dbo.MM_GeolocationByIpAddress ('107.77.215.136')
  --SELECT * from dbo.MM_GeolocationByIpAddress ('12.206.109.2')

  INSERT INTO WebAgent_WireGeoLocationInfo (
		PreparationId ,	TransactionId ,	Control ,
		IpAddress ,	IsSuccessful,	ErrorMessage ,
		CityName ,	CityConfidence ,	Continent ,
		CountryName ,	CountryCode,	CountryConfidence ,
		StateName,	StateCode ,	StateConfidence,
		Latitude ,	Longitude ,	TimeZone ,
		ZipCode ,	ZipCodeConfidence,
		Domain,	Organization ,	ISP ,	UserType ,	XmlData )
  SELECT @PreparationId ,	null ,	0 ,
	     IpAddress ,	IsSuccessful,	ErrorMessage ,
	     CityName ,	CityConfidence ,	Continent ,
	     CountryName ,	CountryCode,	CountryConfidence ,
	     StateName,	StateCode ,	StateConfidence,
	     Latitude ,	Longitude ,	TimeZone ,
	     ZipCode ,	ZipCodeConfidence,
	     Domain,	Organization ,	ISP ,	UserType ,	XmlData 
    from WireSecurity.dbo.MM_GeolocationByIpAddress (@IpAddress)
  if @@ROWCOUNT = 0
     BEGIN
	   SET @ValidResult =1
	   SET @ErrorCode = '10967'
	   SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebLanguageId)
	   RETURN
	 END

  SELECT @IsSuccesful =IsSuccessful,
         @Countrycode = CountryCode,
		 @ErrorMessage = ErrorMessage,
		 @StateCode    = StateCode
    FROM WebAgent_WireGeoLocationInfo
   WHERE PreparationId = @PreparationId   
  IF @@ROWCOUNT = 0
     BEGIN
	   SET @ValidResult =1
	   SET @ErrorCode = '10967'
	   SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebLanguageId)
	   RETURN
	 END
  IF @IsSuccesful = 0
     BEGIN
	   SET @ValidResult =1
	   SET @ErrorCode = '10967'
	   SET @LogErrorMessage  = @ErrorMessage
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebLanguageId)
	   RETURN
	 END
  IF @Countrycode <> 'US'
     BEGIN
	   SET @ValidResult =1
	   SET @ErrorCode = '10968'
	   SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebLanguageId)
	   RETURN
	 END


   SELECT @IPDetectedState = StateName
     FROM WireSearch.dbo.geo_States
    WHERE CountryAbbr = 'USA'
	  AND StateAbbr  = @StateCode
   IF @@ROWCOUNT = 0
      BEGIN
		SET @ErrorCode = '11014' --Could not find state
		SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
		SET @LogErrorMessage = rtrim(@LogErrorMessage)+ ' ' +@StateCode
	    SET @UserErrorMessage = ''
		SET @IPDetectedState  = ''
	  END


  UPDATE WebAgent_WireInPreparation SET IPDetectedState = @IPDetectedState,
                                        WireIPAddress   = @IpAddress
   Where PreparationId = @PreparationId
  if @@ROWCOUNT = 1
  --And @IPDetectedState is not null
  --and @IPDetectedState <> ''
     SET @ValidResult = 0
END