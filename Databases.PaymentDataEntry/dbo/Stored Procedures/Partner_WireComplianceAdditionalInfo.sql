-- =============================================
-- Author:		Franco Atiare
-- Create date: 2023-10-19
-- Description:	Wire Compliance Additional Info
-- =============================================
CREATE PROCEDURE [dbo].[Partner_WireComplianceAdditionalInfo] 
	@PreparationId UNIQUEIDENTIFIER,
	@PartnerId INT,
	@LanguageId INT,
	@SndDOB DATETIME,
	@SndPhone VARCHAR(20),
	@WirePurpose VARCHAR(200),
	@FundSource VARCHAR(120),
	@SndRcvRelationship VARCHAR(80),
	@Occupation VARCHAR(80),
	@Citizenship VARCHAR(40),
	@SndEmployerName VARCHAR(120),
	@SndEmployerPhone VARCHAR(20),
	@RcvDOB DATETIME,
	@SndSsNumber VARCHAR(80),
	@ValidResult INT OUTPUT,-- 0 OK, 1 = Validation Error, 500 = unexpected error
	@ErrorCode varchar(10) OUTPUT,
    @LogErrorMessage varchar(MAX) OUTPUT,
	@UserErrorMessage varchar(300) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE
	@LSenderId INT, 
	@LReceiverId INT

    -- Initialize result to success.
	SET @ValidResult = 0
	SET @ErrorCode = ''
	SET @LogErrorMessage = ''
	SET @UserErrorMessage =  ''

	-- Check for invalid input.
	IF @PreparationId IS NULL
		BEGIN
			SET @ValidResult = 1
			SET @ErrorCode = '11751'
			SET @LogErrorMessage = ''
			SET @UserErrorMessage =  dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
			RETURN
		END

	IF @PartnerId IS NULL OR @PartnerId <= 0
		BEGIN
			SET @ValidResult = 1
			SET @ErrorCode = '11637'
			SET @LogErrorMessage = ''
			SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
			RETURN
		END

	-- Check if record exists
	IF NOT EXISTS (SELECT 1 FROM Partners_WireInPreparation WHERE PreparationID = @PreparationId AND PartnerId = @PartnerId)
		BEGIN
			SET @ErrorCode = '11305'
			SET @ValidResult = 1
			SET @LogErrorMessage = ''
			SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
			RETURN
		END

	IF((SELECT WireStatus FROM Partners_WireInPreparation WHERE PreparationID = @PreparationId AND PartnerId = @PartnerId) <> 'Confirm')
		BEGIN
			SET @ErrorCode = '10211'
			SET @ValidResult = 1
			SET @LogErrorMessage = ''
			SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
			RETURN
		END

	-- Set values from parameters
	SET @LSenderId = (SELECT LSenderId FROM Partners_WireInPreparation WHERE PreparationID = @PreparationId AND PartnerId = @PartnerId)
	SET @LReceiverId = (SELECT LReceiverId FROM Partners_WireInPreparation WHERE PreparationID = @PreparationId AND PartnerId = @PartnerId)

	BEGIN TRAN TRANSACTION_WIRE_COMPLIANCE
	BEGIN TRY

		IF @SndSsNumber IS NOT NULL AND @SndSsNumber <> ''
			BEGIN
				DECLARE	
				@CompSenderIdRecordId int, 
				@UpdResult int,
				@pSenderGroupId int

				SET @pSenderGroupId = 0
				SET @CompSenderIdRecordId = 0

				IF EXISTS (SELECT 1 FROM SenderPartner with(nolock) WHERE LSenderID = @LSenderId AND Partner = @PartnerId)
					SELECT @pSenderGroupId = ISNULL(SenderGroupId, 0) FROM SenderPartner with(nolock) WHERE LSenderID = @LSenderId AND Partner = @PartnerId

				EXEC ImxDirect_Sender_SndIdentification_Save_Abbr 
					@LanguageId, 
					@CompSenderIdRecordId = @CompSenderIdRecordId OUTPUT,
					@SenderGroupId = @pSenderGroupId,
					@IdType = N'SS',
					@IdNumber = @SndSsNumber,
					@IdTypeDesc = N'',
					@IdCountryAbbr = N'USA',
					@IdStateId = NULL,
					@IdExpirationDate = NULL,
					@EnteredBy = 'SYSTEM',
					@UpdResult = @ValidResult OUTPUT,
					@ErrorCode = @ErrorCode OUTPUT,
					@UserErrorMessage = @UserErrorMessage OUTPUT,
					@LogErrorMessage = @LogErrorMessage OUTPUT

				IF @ValidResult = 1 OR @ValidResult = 2 OR @ValidResult = 500
				BEGIN
					ROLLBACK TRAN TRANSACTION_WIRE_COMPLIANCE
					RETURN
				END
			END

		IF @SndDOB IS NOT NULL
			BEGIN
				UPDATE Partners_WireInPreparation SET SndDOB = @SndDOB WHERE PreparationID = @PreparationId AND PartnerId = @PartnerId 
			END

		IF @SndPhone IS NOT NULL AND @SndPhone <> ''
			BEGIN
				UPDATE Senders SET SndPhone = @SndPhone WHERE LSenderId = @LSenderId
			END

		IF @WirePurpose IS NOT NULL AND @WirePurpose <> ''
			BEGIN
				UPDATE Partners_WireInPreparation SET WirePurpose = @WirePurpose WHERE PreparationID = @PreparationId AND PartnerId = @PartnerId
			END

		IF @FundSource IS NOT NULL AND @FundSource <> ''
			BEGIN
				UPDATE Partners_WireInPreparation SET FundSource = @FundSource WHERE PreparationID = @PreparationId AND PartnerId = @PartnerId
			END

		IF @SndRcvRelationship IS NOT NULL AND @SndRcvRelationship <> ''
			BEGIN
				UPDATE Partners_WireInPreparation SET SndRcvRelationship = @SndRcvRelationship WHERE PreparationID = @PreparationId AND PartnerId = @PartnerId
			END

		IF @Occupation IS NOT NULL AND @Occupation <> ''
			BEGIN
				UPDATE Partners_WireInPreparation SET Occupation = @Occupation WHERE PreparationID = @PreparationId AND PartnerId = @PartnerId
			END

		IF @Citizenship IS NOT NULL AND @Citizenship <> ''
			BEGIN
				UPDATE Senders SET Citizenship = @Citizenship WHERE LSenderId = @LSenderId
			END

		IF @SndEmployerName IS NOT NULL AND @SndEmployerName <> ''
			BEGIN
				UPDATE Partners_WireInPreparation SET SndEmployerName = @SndEmployerName WHERE PreparationID = @PreparationId AND PartnerId = @PartnerId
			END

		IF @SndEmployerPhone IS NOT NULL AND @SndEmployerPhone <> ''
			BEGIN
				UPDATE Partners_WireInPreparation SET SndEmployerPhone = @SndEmployerPhone WHERE PreparationID = @PreparationId AND PartnerId = @PartnerId
			END

		IF @RcvDOB IS NOT NULL
			BEGIN
				UPDATE Receivers SET RcvDOB = @RcvDOB WHERE LReceiverId = @LReceiverId
			END

		COMMIT TRAN TRANSACTION_WIRE_COMPLIANCE

	END TRY

	BEGIN CATCH
		ROLLBACK TRAN TRANSACTION_WIRE_COMPLIANCE

		SET @UpdResult = 500
		SET @ErrorCode = '10950' -- The transaction could not be completed
		SET @LogErrorMessage  = ERROR_MESSAGE()
		SET @UserErrorMessage =  dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
	END CATCH

END
GO
