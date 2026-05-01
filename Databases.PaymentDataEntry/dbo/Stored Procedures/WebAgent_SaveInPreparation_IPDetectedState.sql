CREATE PROCEDURE [dbo].[WebAgent_SaveInPreparation_IPDetectedState]
@PreparationId uniqueidentifier,
@CurrentWebLanguageId int,
@IpAddress varchar(50),
@IPDetectedState varchar(40) OUTPUT,
@ValidResult int OUTPUT,
@ErrorCode varchar(10) OUTPUT,
@UserErrorMessage varchar(300) OUTPUT,
@LogErrorMessage varchar(1000) OUTPUT
AS
BEGIN
   DECLARE @IsSuccesful bit
   DECLARE @CountryCode varchar(2)
   DECLARE @ErrorMessage varchar(4000)
   DECLARE @StateCode varchar(2)
   DECLARE @ChannelId int
   DECLARE @Now datetime = getdate()
   DECLARE @StateFrom varchar(30)
   DECLARE @WebAgentUserId int
   DECLARE @Fromdate datetime, @ToDate  datetime
   DECLARE @VendorTransactionId int
   DECLARE @GeolocationInfoId INT
   DECLARE @InsertResult int

   SET @Fromdate = dbo.DateOnly(@now)
   SET @Todate   = @FromDAte

   SET @ErrorCode = ''
   SET @UserErrorMessage = ''
   SET @LogErrorMessage = ''

   	  

   Select @IPDetectedState = IPDetectedState 
     FROM WebAgent_WireInPreparation as p
    Where PreparationId = @PreparationId
	  and WireIPAddress = @IpAddress
	  and (IPDetectedState IS NOT NULL AND IPDetectedState <> '')
	IF @@ROWCOUNT = 1
	   BEGIN
	     SET @ValidResult = 0
		 RETURN
       END

	SELECT @StateFrom       = a.AgState,
	       @ChannelId       = ChannelId,
		   @WebAgentUserId  = WebAgentUserId
	  FROM WebAgent_WireInPreparation as p
	       INNER JOIN WireSearch.dbo.Agencies as a on p.AgSendercode = a.AgencyCode
     Where PreparationId = @PreparationId


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
		 @StateCode    = StateCode,
		 @GeolocationInfoId = GeolocationInfoId
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



--======================LOG TRANSACTION FOR TRANSFER COST TO PARTNER


EXEC SqlMain.WireTransac.dbo.WebAgent_VendorTransactions_Insert
		@CurrentWebLanguageId ,
		@Now ,
		@ChannelId ,
		@StateFrom,
		'MAXMIND',
		'GEOIP2 & PROXY DETECTIO',
		@WebAgentUserId ,
		0,
		@PreparationId ,
		null,
		0, 
		'',
		0,
		'',
		0,
		1,
		0,
		0,
		@FromDate ,
		@ToDate ,
		'SYSTEM',
		@VendorTransactionId  OUTPUT,
		@InsertResult  OUTPUT,
		@ErrorCode  OUTPUT,
		@UserErrorMessage  OUTPUT,
		@LogErrorMessage  OUTPUT

	--	print @VendorTransactionId


  UPDATE   WebAgent_WireGeoLocationInfo SET VendorTransactionId = @VendorTransactionId
   WHERE GeolocationInfoId = @GeolocationInfoId


--==========================================================================



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