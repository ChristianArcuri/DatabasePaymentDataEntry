CREATE PROCEDURE dbo.ImxDirect_Sender_Create
@CurrentLanguageId  INT,
@SndFirstName		VARCHAR(50),
@SndLast1			VARCHAR(50),
@SndLast2			VARCHAR(50),
@SndAddress			VARCHAR(50),
@SndCountryAbbr		VARCHAR(3),
@SndState			VARCHAR(30),
@SndCity			VARCHAR(40),
@SndZip				VARCHAR(15),
@SndPhone			VARCHAR(20),
@Username			VARCHAR(15),
@NoSecLastName		BIT,
@SndEmail           VARCHAR(100),
@IsCellPhone        BIT,
@SndDOB             datetime,
@Result             INT=0 OUTPUT,
@ErrorCode          VARCHAR(10) OUTPUT,
@UserErrorMessage   varchar(300) OUTPUT,
@LogErrorMessage    varchar(MAX) OUTPUT,
@SenderId           INT=0 OUTPUT,
@SndVersionId       INT=0 OUTPUT,
@SenderGroupId      INT=0 OUTPUT

AS
BEGIN
  DECLARE @SndCountry VARCHAR(30)
  SET @Result  = 0
  SELECT @SndCountry= CountryName
    FROM WireSearch.dbo.Geo_Countries
   WHERE CountryAbbr = @SndCountryAbbr
   BEGIN TRY
	 EXEC SqlMain.WireTransac.dbo.Senders_Create_CRM_Fase2
			@pI_WireDate			=NULL,
			@pI_SndFirstName		=@SndFirstName,
			@pI_SndLast1			=@SndLast1,
			@pI_SndLast2			=@SndLast2,
			@pI_SndAddress			=@SndAddress,
			@pI_SndCountry			=@SndCountry,
			@pI_SndState			=@SndState,
			@pI_SndCity				=@SndCity,
			@pI_SndZip				=@SndZip,
			@pI_SndPhone			=@SndPhone,
			@pI_EnteredBy			=@Username,
			@pI_NoSecLastName		=@NoSecLastName,
			@pI_ShowOnCreateWire	=1,
			@pI_SndEmail            =@SndEmail,
			@pI_IsCellPhone         =@IsCellPhone,
			@pi_WebAgentUserId      =0,
			@PI_SndCitizenship      ='',
			@Pi_SndAdditionalPhone  ='',
			@Pi_SndDOB              =@SndDOB,
			@pO_SenderId            =@SenderId OUTPUT,
			@pO_SenderVersionId     =@SndVersionId OUTPUT,
			@pO_SenderGroupId       =@SenderGroupId OUTPUT

 END TRY
 BEGIN CATCH
    SET @LogErrorMessage  = ERROR_MESSAGE()
    if @@TRANCOUNT > 0
      rollback TRAN;
	SET @Result    = 500
	SET @ErrorCode = '11238' -- Error saving the Sender Information
	SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)

 END CATCH  

END