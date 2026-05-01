-- =============================================
-- Author:		Antonio Salgado
-- Create date: 08 Feb 2021
-- Description:	Returns the details of the Wire In Preparation based on the Preparation Id
-- =============================================
CREATE   PROCEDURE [dbo].[WebApi_GetWireInPreparation] 	
	@PreparationId uniqueidentifier,
	@CurrentWebLanguageId int,
	@AgSenderCode varchar(10) OUTPUT,
	@AgSenderId  int OUTPUT,
	@LegalEntityCode varchar(10) OUTPUT,

	@GetResult int OUTPUT , -- 0 = ok, 1 = Validation Error, 500 = unexpected error
	@ErrorCode varchar(10) OUTPUT,
	@UserErrorMessage varchar(300) OUTPUT,
	@LogErrorMessage varchar(MAX) OUTPUT
AS
BEGIN
	SET @GetResult = 0
	SET @ErrorCode = ''
	SET @UserErrorMessage = ''
	SET @LogErrorMessage = ''
	
	BEGIN TRY
	
		SELECT @AgSenderCode = AgSenderCode,
			   @AgSenderId	 = AgSenderId,
			   @LegalEntityCode = LegalEntityCode
		  FROM WebAgent_WireInPreparation
		 WHERE PreparationId = @PreparationId
		 
		 IF @@ROWCOUNT <> 1
		 BEGIN 
			SET @ErrorCode = '11305' 
			SET @UserErrorMessage = Wiresearch.dbo.fnc_EcoMessage_withLanguage(@ErrorCode, @CurrentWebLanguageId)
			SET @GetResult = 1
			RETURN
		 END

	END TRY
	BEGIN CATCH
		SET @LogErrorMessage  = 'WebApi_GetWireInPreparation ' + ERROR_MESSAGE()
		IF @@TRANCOUNT > 0
			rollback TRAN;
		SET @GetResult    = 500
		IF @ErrorCode = '' 
			SET @ErrorCode = '11360' 
		SET @UserErrorMessage = Wiresearch.dbo.fnc_EcoMessage_withLanguage (@ErrorCode, @CurrentWebLanguageId)

	END CATCH
END