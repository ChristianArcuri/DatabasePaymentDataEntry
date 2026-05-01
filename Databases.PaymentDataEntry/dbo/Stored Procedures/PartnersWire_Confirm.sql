-- =============================================
-- Author: Leandro Gordillo
-- CreateDate: 2023-09-26
-- Description:	Generate pin number and update WireStatus to "Confirm" in Partners_WireInPreparation with the PreparationID
-- =============================================
CREATE PROCEDURE [dbo].[PartnersWire_Confirm]
	@PreparationId UNIQUEIDENTIFIER,
	@PartnerId INT,
	@LanguageId INT,
	@PinNumber VARCHAR(20) OUTPUT,
	@GetResult INT OUTPUT, -- 0 = ok, 1 = Validation Error, 500 = unexpected error
	@ErrorCode varchar(10) OUTPUT,
    @LogErrorMessage varchar(MAX) OUTPUT,
	@UserErrorMessage varchar(300) OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @AgPayerCode VARCHAR(10)
	DECLARE @WireStatus VARCHAR(100)
	DECLARE @Cancel VARCHAR(100) = 'Cancel'
    DECLARE @Confirm VARCHAR(100) = 'Confirm'
	DECLARE @Release VARCHAR(100) = 'Release'

	-- Initialize result to success.
	SET @GetResult = 0
	SET @ErrorCode = ''
	SET @LogErrorMessage = ''
	SET @UserErrorMessage =  ''

	-- Check for invalid input.
	IF @PreparationId IS NULL
		BEGIN
			SET @GetResult = 1
			SET @ErrorCode = '100' -- {0} required
			SET @LogErrorMessage = ''
			SET @UserErrorMessage =  REPLACE(dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId),'{0}', 'PreparationId')
			RETURN
		END

	-- Check for invalid partnerId.
	IF @PartnerId IS NULL OR @PartnerId = ''
		BEGIN
			SET @GetResult = 1
			SET @ErrorCode = '11637' -- The partner must be selected
			SET @LogErrorMessage = ''
			SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
			RETURN
		END

	-- Fetch the AgPayerCode.
	SELECT @AgPayerCode = LTRIM(RTRIM(AgPayerCode))
	FROM Partners_WireInPreparation
	WHERE PreparationId = @PreparationId

	-- Check if the record exists.
	IF @AgPayerCode IS NULL OR @AgPayerCode = ''
		BEGIN
			SET @GetResult = 1
			SET @ErrorCode = '11305' -- Could not find the preparation record
			SET @LogErrorMessage  = ''
			SET @UserErrorMessage =  dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
			RETURN
		END

	-- Validate existence of Partner-Wire record existence.
	IF NOT EXISTS (SELECT 1
	FROM Partners_WireInPreparation
	WHERE PreparationId = @PreparationId AND PartnerId = @PartnerId)
		BEGIN
			SET @GetResult = 1
			SET @ErrorCode = '11305' -- Could not find the preparation record
			SET @LogErrorMessage  = ''
			SET @UserErrorMessage =  dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
			RETURN
		END

	-- Validate Status.
	SELECT @WireStatus = WireStatus 
	FROM Partners_WireInPreparation
	WHERE PreparationId = @PreparationId AND PartnerId = @PartnerId
		
	IF @WireStatus = @Confirm
	BEGIN
		SET @GetResult = 1
		SET @ErrorCode = '11761' -- The wire is already confirmed
		SET @LogErrorMessage  = ''
		SET @UserErrorMessage =  dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
		RETURN
	END

	IF @WireStatus = @Release
	BEGIN
		SET @GetResult = 1
		SET @ErrorCode = '11762' -- The wire is already released
		SET @LogErrorMessage  = ''
		SET @UserErrorMessage =  dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
		RETURN
	END

	IF @WireStatus = @Cancel
	BEGIN
		SET @GetResult = 1
		SET @ErrorCode = '1317' -- This Wire-Transfer is already canceled.
		SET @LogErrorMessage  = ''
		SET @UserErrorMessage =  dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
		RETURN
	END
	BEGIN TRAN TRANSACTION_WIRE_CONFIRM
	BEGIN TRY
		-- Fetch the PIN Number.
		EXEC WireKeys.dbo.sps_GetPINNumber @AgPayerCode, @PinNumber OUTPUT

		-- Check for a valid PIN Number.
        IF COALESCE(@PinNumber, '') = ''
			BEGIN
				SET @GetResult = 1
				SET @ErrorCode = '11307' -- There was on error creating the PIN NUMBER, Please call Technical Support
				SET @LogErrorMessage  = ''
				SET @UserErrorMessage =  dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)

				ROLLBACK TRAN TRANSACTION_WIRE_CONFIRM
				RETURN
			END

		-- Update the record.
		UPDATE Partners_WireInPreparation 
		SET WireStatus = @Confirm, 
		PinNumber = @PinNumber
		WHERE PreparationId = @PreparationId AND PartnerId = @PartnerId

		COMMIT TRAN TRANSACTION_WIRE_CONFIRM

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN TRANSACTION_WIRE_CONFIRM

		SET @GetResult = 1
		SET @ErrorCode = '10950' -- The transaction could not be completed
		SET @LogErrorMessage  = ERROR_MESSAGE()
		SET @UserErrorMessage =  dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
	END CATCH

	RETURN
END
