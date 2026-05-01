CREATE PROCEDURE [dbo].[WebAgentSenderCreateFromConsumerApp]
@WebAgentUserId int,
@SenderId int OUTPUT,
@SndCreateResult				int			OUTPUT,
	--0 = ok
	--500 = error
@ErrorCode						varchar(10)	 OUTPUT,
@UserErrorMessage				varchar(300) OUTPUT,
@LogErrorMessage				varchar(1000) OUTPUT
AS
BEGIN
	DECLARE @SameSenderId int,
			@SndFirstName varchar(50),
			@SndLastName1 varchar(50),
			@SndLastName2 varchar(50),
			@SndAddress varchar(50),
			@SndCountry varchar(30),
			@SndState varchar(30),
			@SndCity varchar(40),
			@SndZipCode varchar(15),
			@SndPhone varchar(20),
			@SndNoSecLastName bit,
			@SndEmail varchar(100),
			@SndLastVersionId int,
			@SenderGroupId int,
			@OptStatus char(1)
	BEGIN TRY 

	 SELECT @SameSenderId=SameSenderId,
			@SndEmail=WebAgentUserName
	   FROM WireSecurity.dbo.WebAgent_Users
	  WHERE WebAgentUserId = @WebAgentUserId


	 SELECT  @SndFirstName		= s.SndFirstName
			,@SndLastName1		= s.SndLast1
			,@SndLastName2		= s.SndLast2
			,@SndAddress		= s.SndAddress
			,@SndCountry		= s.SndCountry
			,@SndState			= s.SndState
			,@SndCity			= s.SndCity
			,@SndZipCode		= s.SndZip
			,@SndPhone			= s.SndPhone
			,@OptStatus			= s.OptStatus
			,@SndNoSecLastName	= s.NoSecLastName
	   FROM SQLMAIN.WireTransac.dbo.CRM_SameSenders as ss
 INNER JOIN SQLMAIN.WireTransac.dbo.Senders as s ON ss.LastSenderId = s.SenderId
	  WHERE ss.SameSenderId = @SameSenderId


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
										1 ,
										@WebAgentUserId,
										'',
										'',
										null,
										@SenderId OUTPUT,
										@SndLastVersionId OUTPUT,
										@SenderGroupId OUTPUT
				IF @SenderId > 0
					BEGIN
						update SqlMain.WireTransac.dbo.Senders  
						   Set OptStatus = @OptStatus, OptStatusDate = getdate()
						 where SenderId  = @SenderId				 
				 
						UPDATE WireSecurity.dbo.WebAgent_Users SET SenderId        = @SenderId,
																   AlreadyCustomer = 1
						WHERE WebAgentUserId = @WebAgentUserId
				  
					END
END TRY
BEGIN CATCH
	SET @LogErrorMessage  = ERROR_MESSAGE()
	SET @SndCreateResult  = 500
	SET @ErrorCode        = '11283'
    SET @UserErrorMessage = Wiresearch.dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)--An Unexpected error has occurred, please try again and if the error persists contact technical support
END CATCH 
END