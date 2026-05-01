CREATE PROCEDURE [dbo].[WebAgent_SenderId_Save_Fase2]
@CompSenderIdRecordId int OUTPUT,
@WebAgentUserId int,
@CurrentWebLanguageId int,
@IdType varchar(5), 
@IdNumber varchar(80), 
@IdTypeDesc varchar(30), 
@IdCountry varchar(30), 
@IdState varchar(40), 
@IdExpirationDate datetime,
@UpdResult int OUTPUT,
@ErrorCode  varchar(10) OUTPUT,
@UserErrorMessage varchar(300) OUTPUT,
@LogErrorMessage varchar(MAX) OUTPUT
AS
BEGIN
  DECLARE @SenderGroupId int
  DECLARE @EnteredBy varchar(15)
  DECLARE @NewId bit
  DECLARE @IdTypeName varchar(50)
  DECLARE @SS bit
  DECLARE @PhotoId bit
  DECLARE @Passport bit

  
  SET @ErrorCode = ''
  SET @UserErrorMessage = ''
  SET @LogErrorMessage  = ''
  SET @UpdResult = 2
  
  
  IF @WebAgentUserId = 0
     BEGIN
	   SET @ErrorCode = '10802'  --Usuario no puede ser 0
	   SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage ('10809',@CurrentWebLanguageId) --Unable to Save the Id at this time, Please Try Again Later
	   SET @UpdResult = 2
	   RETURN
	 END

  SELECT @IdTypeName = IdTypeName,
         @SS         = SS,
         @PhotoId    = PhotoId ,
         @Passport   = Passport
    FROM WireCompliance.dbo.Comp_IdTypes
   WHERE IdType = @IdType
  IF @@ROWCOUNT = 0
     BEGIN
	   SET @ErrorCode = '10807'  --Tipo de Identificacion Invalida
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebLanguageId)
	   SET @LogErrorMessage  = ''
	   SET @UpdResult = 1
	   RETURN
	 END
  if RTRIM(@IdNumber) = ''
     BEGIN
	   SET @ErrorCode = '10808'  --El Numero de Identificacion no puede estar vacio
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentWebLanguageId)
	   SET @LogErrorMessage    = ''
	   SET @UpdResult = 1
	   RETURN
	 END

	--Validar fecha de Vencimiento??


  SELECT @SenderGroupId = SenderGroupId
    FROM SqlMain.WireTransac.dbo.Senders
   WHERE WebAgentUserId = @WebAgentUserId
  IF @@ROWCOUNT = 0
     BEGIN 
	   SET @ErrorCode = '10795' --Remitente no pudo ser encontrado para ese usuario
	   SET @UpdResult = 2
	   SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage ('10809',@CurrentWebLanguageId) --Unable to Save the Id at this time, Please Try Again Later
	   RETURN
	 END
  
    IF @CompSenderIdRecordId = 0
       BEGIN
	     SET @NewId = 1
	   END
    ELSE BEGIN
         SET @NewId = 0
       END
	SET @EnteredBy = 'WEBAGENT'
	EXEC SQLMain.WireTransac.dbo.Comp_SenderId_InsEdit_fase2   @NewId,@CompSenderIdRecordId OUTPUT,@SenderGroupId,
													@IdType ,@IdTypeName, @IdNumber , 
													@IdTypeDesc , 
													@IdCountry , 
													@IdState , 
													@IdExpirationDate ,
													@EnteredBy

	--IF  (@PhotoId = 1 OR @Passport = 1)
	--AND (EXISTS (SELECT * FROM SqlMain.WireTransac.dbo.Comp_WireOnHold_DocNeeded
	--              WHERE WebAgentUserId = @WebAgentUserId
	--			    AND RequirePhotoID = 1 ))
	--   BEGIN
	--		 UPDATE SqlMain.WireTransac.dbo.Comp_WireOnHold_DocNeeded SET RequirePhotoID = 0
	--		  WHERE WebAgentUserId = @WebAgentUserId
	--			AND RequirePhotoID = 1
	--   END

	--IF  (@SS = 1)
	--AND (EXISTS (SELECT * FROM SqlMain.WireTransac.dbo.Comp_WireOnHold_DocNeeded
	--              WHERE WebAgentUserId = @WebAgentUserId
	--			    AND RequireSS = 1 ))
	--   BEGIN
	--		 UPDATE SqlMain.WireTransac.dbo.Comp_WireOnHold_DocNeeded SET RequireSS = 0
	--		  WHERE WebAgentUserId = @WebAgentUserId
	--			AND RequireSS = 1
	--   END


  SET @UpdResult = 0
END