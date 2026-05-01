
CREATE PROCEDURE [dbo].[ImxDirect_WIRE_GetCardDirectWireStatus]	
	@CurrentLanguageId int,
	@AgencyCode CHAR(10),
	@WireId int,
	@StsCancel int OUTPUT,
	@Result int OUTPUT,--0 ok, 1 error de validacion, 500 error inesperado
	@ErrorCode varchar(10) OUTPUT,
	@LogErrorMessage varchar(max) OUTPUT,
	@UserErrorMessage varchar(300) OUTPUT
AS
BEGIN
	BEGIN TRY
	
		SET @Result =0
		SET @ErrorCode ='' 
		SET @LogErrorMessage ='' 
		SET @UserErrorMessage =''
		SET @StsCancel = 0

		SELECT @StsCancel=StsCancel
		  FROM Wires
		 WHERE AgSenderCode = @AgencyCode
		   AND WireId = @WireId

	END TRY
	BEGIN CATCH
		SET @LogErrorMessage  = ERROR_MESSAGE()    
		SET @Result    = 500
		SET @ErrorCode = '11283' -- An Anexpected error has occurred, please try again and if the error persists contact technical support
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
	END CATCH
END