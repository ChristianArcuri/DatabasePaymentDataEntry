-- =============================================
-- Author: Leandro Gordillo
-- CreateDate: 2023-10-23
-- Description:	Get SenderGroupId By PartnerId and SenderPartnerID
-- =============================================
CREATE PROCEDURE [dbo].[GetSenderGroupIdBySenderPartnerId]
	@SenderId INT,
	@PartnerId INT,
	@SenderGroupId INT OUTPUT,
	@CurrentLanguageId INT,
	@ValidResult INT OUTPUT,
    @ErrorCode varchar(10) OUTPUT,
    @LogErrorMessage VARCHAR(300) OUTPUT,
    @UserErrorMessage VARCHAR(300) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET @ValidResult = 0
	SET @ErrorCode = ''
	SET @UserErrorMessage = ''
    SET @LogErrorMessage = ''

	IF @PartnerId IS NULL OR @PartnerId <= 0
		BEGIN
			SET @ValidResult = 1
		 	SET @ErrorCode = '11637'
	    	SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
        	SET @LogErrorMessage = RTRIM(@LogErrorMessage)
		RETURN
		END
		 
		IF @SenderId IS NULL OR @SenderId <= 0
		BEGIN
			SET @ValidResult = 1
		 	SET @ErrorCode = '11300'
	    	SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
        	SET @LogErrorMessage = ''
		RETURN
		END

	SELECT @SenderGroupId = SenderGroupId 
	FROM SenderPartner WITH(NOLOCK) 
	WHERE SenderPartnerID = @SenderId AND Partner = @PartnerId
END

