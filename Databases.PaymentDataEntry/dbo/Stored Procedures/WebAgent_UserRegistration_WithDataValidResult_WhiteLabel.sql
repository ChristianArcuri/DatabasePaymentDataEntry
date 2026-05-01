CREATE PROCEDURE [dbo].[WebAgent_UserRegistration_WithDataValidResult_WhiteLabel]
@WebAgentUserId int,
@ChannelId int,
@SenderId int OUTPUT,
@SndFirstName varchar(50),
@SndLastName1 varchar(50),
@SndLastName2 varchar(50),
@SndNoSecLastName bit,
@SndAddress varchar(50),
@SndCountry  varchar(30),
@SndState  varchar(30),
@SndCity  varchar(40),
@SndZipCode  varchar(15),
@SndCellPhone  varchar(20),
@SndAdditionalPhone  varchar(20),
@SndEmail  varchar(150),
@SndCitizenship  varchar(50),
@SndDOB datetime,
@SndLanguageId int,
@RegistrationIPAddress varchar(100),
@LoyaltyCardNumber varchar(50),
@OptStatus char(1),
@AuthyId varchar(10),
@RegValid_RequestId int,
@RegDataValidResult int,
@Success BIT OUTPUT,
@SameSenderId int OUTPUT,
@Terms int = NULL
AS
BEGIN

  DECLARE @SndFullName varchar(150)
  DECLARE @SndPhone varchar(20)
  DECLARE @IsCellPhone bit
  DECLARE @SndLastVersionId int
  DECLARE @SenderGroupId int
  DECLARE @RegistrationState varchar(40)
  DECLARE @StsRegDataValidResult int
  DECLARE @AlreadyCustomer bit
  DECLARE @PartnerId int =0
  DECLARE @VendorTransactionId INT 


  SET @RegistrationState = @SndState --??
  SET @Success = 0
  SET @SenderId = 0
  SET @SameSenderId = 0
BEGIN TRY  

--======================================================================================

  SELECT @SenderId = SenderId 
    FROM WireSecurity.dbo.WebAgent_Users 
   WHERE WebAgentUserId = @WebAgentUserId
     AND UserStatus = 'A'
  IF @@ROWCOUNT = 1
     BEGIN
	   SET @Success = 1
	   SET @SameSenderId =0
	   RETURN
	 END
  SET @SenderId = 0

  SELECT @PartnerId = PartnerId
    FROM WireSearch.dbo.Switch_Channels 
   WHERE ChannelId = @ChannelId

  IF EXISTS ( SELECT *
				FROM WireSecurity.dbo.WebAgent_Users 
			   WHERE WebAgentUserName = @SndEmail
				 AND UserStatus = 'D')
	  BEGIN
	    SET @Success = 0  --No se puede crear otra vez un usuario que ha sido denegado
		SET @SameSenderId =0
	   RETURN
	  END

  SET @SndCellPhone = dbo.JustNum(@SndCellPhone)  --Lo agregue el 16 Sep 2020 Geru

  --SET @SndCountry = 'USA' --Pedir que modifique US x USA

  --SELECT @SndState = StateName
  --  FROM WireSearch.dbo.Geo_States
  -- WHERE CountryAbbr = @SndCountry
  --   AND StateAbbr   = @SndState
  
  --SELECT @SndCitizenship = CountryName
  -- FROM WireSearch.dbo.Geo_Countries
  --WHERE CountryAbbr = @SndCitizenship


  IF @RegDataValidResult not in(0,1)
       SET @StsRegDataValidResult = 2
  ELSE SET @StsRegDataValidResult = @RegDataValidResult

  INSERT INTO WireSecurity.dbo.WebAgent_Users
           (WebAgentUserId
           ,WebAgentUserName
           ,WebAgentUserCellPhone
           ,WebAgentyUserLanguageId
           ,RegistrationIPAddress
           ,RegistrationState
           ,Created
		   ,SenderId
		   ,AuthyId
		   ,StsRegDataValidResult 
		   ,PartnerId 
		   ,ChannelId
		   ,GrantAccessToWA
		   ,TermsAndConditions
		   ,TermsAndConditionsAcceptedOn)
     VALUES
           (@WebAgentUserId
           ,@SndEmail
           ,@SndCellPhone
           ,@SndLanguageId
           ,@RegistrationIPAddress
           ,@RegistrationState
           ,getdate()
		   ,@SenderId --0
		   ,@AuthyId
		   ,@StsRegDataValidResult
		   ,@PartnerId
		   ,@ChannelId
		   ,1
		   ,@Terms
		   ,getdate())

  
  SET @SndFirstName = dbo.fn_RemoveAccent(@SndFirstName)
  SET @SndLastName1 = dbo.fn_RemoveAccent(@SndLastName1)
  SET @SndLastName2 = dbo.fn_RemoveAccent(@SndLastName2)

  SET @SndFullName = rtrim(@SndFirstName)+' '+rtrim(@SndLastName1)+' '+rtrim(@SndLastName2)

  IF @RegValid_RequestId IS NOT NULL AND @RegValid_RequestId >0
     BEGIN
	   UPDATE WireSecurity.dbo.WebAgent_KBAProcesses SET WebAgentUserId = @WebAgentUserId
	    WHERE ProviderId = 'WHITEPAGES'
		  AND ProviderRecordId = @RegValid_RequestId
		  AND WebAgentUserId = 0

	 --================NEW TO BIND TRANSACTION WITH A USER===========================
		SELECT @VendorTransactionId =VendorTransactionId  
		  FROM WireSecurity.dbo.WP_RequestId_VendorTransactionId
		 WHERE RegValid_RequestId = @RegValid_RequestId

		 UPDATE SqlMain.WireTransac.dbo.WebAgent_VendorTransactions SET WebAgentUserId = @WebAgentUserId
		  WHERE VendorTransactionId = @VendorTransactionId

	 END

  IF rtrim(dbo.justNum(@SndCellPhone)) <> ''
     BEGIN
	   SET @SndPhone = rtrim(dbo.justNum(@SndCellPhone))
	   SET @IsCellPhone = 1
	   SET @SndAdditionalPhone = ISNULL(@SndAdditionalPhone,'')
	 END
  ELSE BEGIN
        SET @SndPhone = rtrim(dbo.justNum(@SndAdditionalPhone))
		SET @IsCellPhone = 0
		SET @SndAdditionalPhone = ''
	   END

  IF @SenderId = 0
     BEGIN
	   EXECUTE SqlMain.WireTransac.dbo.Senders_Create_CRM_Fase2    NULL,
									@SndFirstName,
									@SndLastName1,
									@SndLastName2,
									@SndAddress,
									@SndCountry,
									@SndState,
									@SndCity,
									@SndZipCode,
									@SndPhone,
									'WebAgent',
									@SndNoSecLastName,
									1,
									@SndEmail ,
	                                @IsCellPhone ,
									@WebAgentUserId,
									@SndCitizenship,
									@SndAdditionalPhone,
									@SndDOB,
									@SenderId OUTPUT,
									@SndLastVersionId OUTPUT,
									@SenderGroupId OUTPUT
			IF @SenderId > 0
			   BEGIN
			     update SqlMain.WireTransac.dbo.Senders  
                    Set OptStatus = @OptStatus, OptStatusDate = getdate()
                  where SenderId  = @SenderId

			     EXEC SqlMain.WireTransac.dbo.CRM_SameSenders_Create 0, null,  0, '', 0, @SenderId;
				 SET @Success = 1
				 SELECT @SameSenderId = SameSenderId FROM SqlMain.WireTransac.dbo.Senders Where SenderId = @SenderId
				
				 
				 EXEC SqlMain.WireTransac.dbo.WebAgent_UserIsAlreadyCustomer @SenderId,@AlreadyCustomer output 
				 
				 UPDATE WireSecurity.dbo.WebAgent_Users SET SenderId        = @SenderId,
				                                            AlreadyCustomer = @AlreadyCustomer
				  WHERE WebAgentUserId = @WebAgentUserId


				  
		 

				  --DECLARE @PromoCode varchar(20) ,@PromoAssigned bit 
				  --EXEC WirePricing.dbo.WebAgent_VerifyAndAssignRegistrationPromo @SameSenderId ,@PromoCode OUTPUT,@PromoAssigned OUTPUT
				  
			   END

       
	 END
	

  
  
END TRY
BEGIN CATCH
  DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = 'WebAgent_UserRegistration - '+ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH  


  
END