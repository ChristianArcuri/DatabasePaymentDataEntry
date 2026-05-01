-----------------------------------------------------------------------
-- Author       Geraldine Schnaider
-- Created      2021-04-15
-- Purpose      Created for debit card program 
-----------------------------------------------------------------------
CREATE PROCEDURE [dbo].[ImxDirect_Sender_SndIdentification_Save_V2]
@CurrentLanguageId int,
@CompSenderIdRecordId int OUTPUT,
@SenderGroupId int,
@IdType varchar(5), 
@IdNumber varchar(80), 
@IdTypeDesc varchar(50), 
@IdCountryAbbr varchar(3),
@IdStateId int,
@IdExpirationDate datetime,
@EnteredBy varchar(15),
@UpdResult int OUTPUT,
@ErrorCode  varchar(10) OUTPUT,
@UserErrorMessage varchar(300) OUTPUT,
@LogErrorMessage varchar(MAX) OUTPUT
AS
BEGIN

  SET @IdTypeDesc = ''


  DECLARE @NewId bit
  DECLARE @IdTypeName varchar(50)
  DECLARE @SS bit
  DECLARE @PhotoId bit
  DECLARE @Passport bit
  DECLARE @ExpirationDateRequired bit
  DECLARE @IdCountry varchar(30)
  DECLARE @IdState varchar(40)


  SELECT @IdCountry = CountryName
    FROM WireSearch.dbo.Geo_Countries
  WHERE CountryAbbr = @IdCountryAbbr

  IF @IdStateId IS NOT NULL
  AND @IdStateId > 0
      BEGIN
		  SELECT @IdState = StateName
			FROM WireSearch.dbo.Geo_States
		  WHERE CountryAbbr = @IdCountryAbbr
			AND StateId     = @IdStateId
	   END
	ELSE SET @IdState = ''

  
  SET @ErrorCode = ''
  SET @UserErrorMessage = ''
  SET @LogErrorMessage  = ''
  SET @UpdResult = 2
  
  
  IF @SenderGroupId = 0
     BEGIN
	   SET @ErrorCode = '11239'  --Sender Group Id cannot be 0
	   SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage ('10809',@CurrentLanguageId) --Unable to Save the Id at this time, Please Try Again Later
	   SET @UpdResult = 2
	   RETURN
	 END

  SELECT @IdTypeName = IdTypeName,
         @SS         = SS,
         @PhotoId    = PhotoId ,
         @Passport   = Passport,
		 @ExpirationDateRequired = ExpirationDateRequired 
    FROM WireCompliance.dbo.Comp_IdTypes
   WHERE IdType = @IdType
  IF @@ROWCOUNT = 0
     BEGIN
	   SET @ErrorCode = '10807'  --Tipo de Identificacion Invalida
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
	   SET @LogErrorMessage  = ''
	   SET @UpdResult = 1
	   RETURN
	 END
  if RTRIM(@IdNumber) = ''
     BEGIN
	   SET @ErrorCode = '10808'  --El Numero de Identificacion no puede estar vacio
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
	   SET @LogErrorMessage    = ''
	   SET @UpdResult = 1
	   RETURN
	 END

	--Validar fecha de Vencimiento??

	IF @ExpirationDateRequired = 1
   AND @IdExpirationDate IS NULL
       BEGIN
		   SET @ErrorCode = '11240'  --Please enter the Identification Expiration Date
		   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
		   SET @LogErrorMessage    = ''
		   SET @UpdResult = 1
	   RETURN
	 END

	 IF @ExpirationDateRequired = 0
   AND @IdExpirationDate < dbo.DateOnly(getdate())
       BEGIN
		   SET @ErrorCode = '11241'  --The identification is already expired
		   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
		   SET @LogErrorMessage    = ''
		   SET @UpdResult = 1
	   RETURN
	 END
 
  
    IF @CompSenderIdRecordId = 0
       BEGIN
	     SET @NewId = 1
	   END
    ELSE BEGIN
         SET @NewId = 0
       END


	BEGIN TRY
	EXEC SQLMain.WireTransac.dbo.Comp_SenderId_InsEdit_fase2   @NewId,@CompSenderIdRecordId OUTPUT,@SenderGroupId,
													@IdType ,@IdTypeName, @IdNumber , 
													@IdTypeDesc , 
													@IdCountry , 
													@IdState , 
													@IdExpirationDate ,
													@EnteredBy

     
	 SET @UpdResult = 0
   END TRY
   BEGIN CATCH
    SET @LogErrorMessage  = ERROR_MESSAGE()
    if @@TRANCOUNT > 0
      rollback TRAN;
	SET @UpdResult    = 500
	SET @ErrorCode = '11242' -- Error saving Sender Idenfitication Information
	SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)

 END CATCH 

  
END
