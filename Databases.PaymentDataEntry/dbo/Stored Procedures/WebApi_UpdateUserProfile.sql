CREATE PROCEDURE [dbo].[WebApi_UpdateUserProfile]
@WebAgentUserId int,
@Userpassword varchar(100),
@Salt varchar(100),
@PasswordExpiration datetime,
@FacebookId varchar(50),
@AppleId varchar(100),
@Success BIT OUTPUT
AS
BEGIN

  SET @Success = 0
  SET @WebAgentUserId = ISNULL(@WebAgentUserId, 0)

BEGIN TRY  

	IF (@WebAgentUserId = 0)
	BEGIN
		SET @Success = 1
		RETURN
	END

	UPDATE WireSecurity.dbo.WebAgent_Users
	   SET   UserPassword		= @Userpassword
			,Salt				= @Salt
			,PasswordExpiration = @PasswordExpiration
			,FacebookId			= @FacebookId
			,AppleId			= @AppleId
	 WHERE WebAgentUserId = @WebAgentUserId

	 SET @Success = 1

END TRY
BEGIN CATCH
  DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = 'WebApi_UpdateUserProfile - '+ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH  


  
END