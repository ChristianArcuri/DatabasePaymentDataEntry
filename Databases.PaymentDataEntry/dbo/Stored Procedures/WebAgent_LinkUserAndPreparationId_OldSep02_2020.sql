CREATE PROCEDURE [dbo].[WebAgent_LinkUserAndPreparationId_OldSep02_2020]
@WebAgentUserId int,
@PreparationId UniqueIdentifier ,
@LinkResult int OUTPUT ,-- 0 OK , 500 Error
@LogErrorMessage varchar(MAX) OUTPUT
AS
BEGIN
  DECLARE @SenderId int
  DECLARE @SameSenderId int
  DECLARE @UserStatus char(1)

  SET @LogErrorMessage = ''

  SELECT @SenderId = SenderId,
         @UserStatus = UserStatus
    FROM WireSecurity.dbo.WebAgent_Users 
   WHERE WebAgentUserId = @WebAgentUserId
  IF @@ROWCOUNT = 0
     BEGIN
	  SET @LinkResult = 500
      SET @LogErrorMessage = 'No se pudo encontrar el SenderId para el Usuario '+convert(varchar,@WebAgentUserId)
	  RETURN 
	 END

  IF @UserStatus <> 'A'
     BEGIN
	   SET @LinkResult = 500
       SET @LogErrorMessage = 'This User is not longer Active '+convert(varchar,@WebAgentUserId)
	  RETURN 
	 END

  SELECT @SameSenderId = SameSenderId
    FROM sqlmain.wiretransac.dbo.senders
  --  FROM WireSearch.dbo.Senders
   WHERE SenderId = @SenderId
  IF @@ROWCOUNT = 0
     BEGIN
	  SET @LinkResult = 500
      SET @LogErrorMessage = 'No se pudo encontrar el SameSenderId para el Sender '+convert(varchar,@SenderId)
	  RETURN 
	 END

   UPDATE WebAgent_WireInPreparation SET WebAgentUserId  = @WebAgentUserId,
								         SenderId        = @SenderId,
								         SameSenderId    = @SameSenderId
	WHERE PreparationId = @PreparationId
   IF @@ROWCOUNT = 0
      BEGIN
	    SET @LinkResult = 500
        SET @LogErrorMessage = 'No se pudo actualizar WebAgent_WireInPreparation '+convert(varchar,@PreparationId)
	    RETURN 
	  END


     SET @LinkResult = 0


END