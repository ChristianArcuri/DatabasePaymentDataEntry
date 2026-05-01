
CREATE PROCEDURE [dbo].[BillPayment_BT_SenderServiceAccounts_UpdateAccount]
	@CurrentLanguageId int,
	@BTSenderServiceAccountId int,
	@BTBillerAddressId int,
	@BTBillerAddress varchar(200),
	@BTPayeeId bigint,
	@UpdatedBy varchar(15),
	@UpdResult int OUTPUT , --0 ok 500 error
	@ErrorCode varchar(10) OUTPUT,
	@UserErrorMessage varchar(300) OUTPUT,
	@LogErrorMessage varchar(MAX) OUTPUT
AS
BEGIN
	SET @UpdResult = 0
	SET @ErrorCode =''
	SET @UserErrorMessage =''
	SET @LogErrorMessage =''

	BEGIN TRY
		IF NOT EXISTS (SELECT TOP 1 BTSenderId
						 FROM SqlMain.WireTransac.dbo.BT_SenderServiceAccounts
						WHERE
							BTSenderServiceAccountId = @BTSenderServiceAccountId
						AND BTPayeeId				 = @BTPayeeId
						AND (BTBillerAddressId IS NULL OR BTBillerAddressId = @BTBillerAddressId)
						AND (BTBillerAddress IS NULL OR BTBillerAddress = @BTBillerAddress))
		BEGIN
			UPDATE SqlMain.WireTransac.dbo.BT_SenderServiceAccounts
			   SET BTPayeeId			= @BTPayeeId
				  ,BTBillerAddressId	= @BTBillerAddressId
				  ,BTBillerAddress		= @BTBillerAddress
				  ,UpdatedBy			= @UpdatedBy
				  ,Updated				= GETDATE()
			WHERE
				BTSenderServiceAccountId = @BTSenderServiceAccountId
		END ELSE
		BEGIN
			UPDATE SqlMain.WireTransac.dbo.BT_SenderServiceAccounts
			   SET Updated = GETDATE()
			 WHERE
				BTSenderServiceAccountId = @BTSenderServiceAccountId
		END
	END TRY
	BEGIN CATCH
		SET @LogErrorMessage  = ERROR_MESSAGE()
		SET @UpdResult = 500
		SET @ErrorCode = '11455' --The Receiver couldn't be updated
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
	END CATCH  
END
