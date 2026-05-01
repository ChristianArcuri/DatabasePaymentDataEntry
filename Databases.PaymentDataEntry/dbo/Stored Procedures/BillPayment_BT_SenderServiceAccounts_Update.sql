
CREATE PROCEDURE BillPayment_BT_SenderServiceAccounts_Update
	@CurrentLanguageId int,
	@BTSenderServiceAccountId int,
	@Visible bit,
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
		UPDATE SqlMain.WireTransac.dbo.BT_SenderServiceAccounts
		   SET ServiceShow = @Visible
			  ,UpdatedBy = @UpdatedBy
			  ,Updated = GETDATE()
		WHERE
			BTSenderServiceAccountId = @BTSenderServiceAccountId
	END TRY
	BEGIN CATCH
		SET @LogErrorMessage  = ERROR_MESSAGE()
		SET @UpdResult = 500
		SET @ErrorCode = '11455' --The Receiver couldn't be updated
		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)

	END CATCH  
END
