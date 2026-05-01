CREATE PROCEDURE dbo.Partners_CancellationWire
	@CurrentLanguageId INT,
	@PinNumber Varchar(30) = NULL,
	@CancelReasonID INT = NULL,
	@CancelBy Varchar(30) = NULL,
	@PartnerID INT = NULL,
    @ValidResult INT OUTPUT, 
    @ErrorCode varchar(10) OUTPUT,
    @LogErrorMessage VARCHAR(300) OUTPUT,
    @UserErrorMessage VARCHAR(300) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON
    BEGIN TRY
            DECLARE @PreparationTableStatus VARCHAR(100) = ''
            DECLARE @Cancel VARCHAR(100) = 'Cancel'
            DECLARE @Confirm VARCHAR(100) = 'Confirm'
			DECLARE @InProgress VARCHAR(100) = 'In Process'
			DECLARE @Release VARCHAR(100) = 'Release'
			DECLARE @AgSenderCode VARCHAR(10) = ''
			DECLARE @CancelResult INT = 0
			DECLARE @CancelType CHAR(1) = ''
			
		SET @ValidResult = 0
		
		 IF @PartnerId IS NULL OR @PartnerId <= 0
		 	BEGIN
				SET @ValidResult = 1
		 	    SET @ErrorCode = '11637'
	    		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
        		SET @LogErrorMessage = RTRIM(@LogErrorMessage)
		 	RETURN
		 END
		 
		 IF @CancelReasonID IS NULL OR @CancelReasonID <= 0
		 	BEGIN
				SET @ValidResult = 1
		 	    SET @ErrorCode = '1827'
	    		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
        		SET @LogErrorMessage = RTRIM(@LogErrorMessage)
		 	RETURN
		 END
		 
		 IF @PinNumber IS NULL OR @PinNumber = ''
		 	BEGIN
				SET @ValidResult = 1
		 	    SET @ErrorCode = '1794'
	    		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
        		SET @LogErrorMessage = RTRIM(@LogErrorMessage)
		 	RETURN
		 END
		 
		 IF @CancelBy IS NULL OR @CancelBy = ''
		 	BEGIN
				SET @ValidResult = 1
		 	    SET @ErrorCode = '11193'
	    		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
        		SET @LogErrorMessage = RTRIM(@LogErrorMessage)
		 	RETURN
		 END
		 
		 SELECT 
		 @PreparationTableStatus = WireStatus,
		 @AgSenderCode = AgSenderCode
		 FROM dbo.Partners_WireInPreparation 
		 WHERE 
			PinNumber = @PinNumber AND 
			PartnerId = @PartnerID
			
		 IF @PreparationTableStatus IS NULL OR @PreparationTableStatus = ''
		 	BEGIN
				SET @ValidResult = 1
		 	    SET @ErrorCode = '11471'
	    		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
        		SET @LogErrorMessage = RTRIM(@LogErrorMessage)
		 	RETURN
		 END 
			
		 IF @PreparationTableStatus = @Cancel
		 BEGIN
		 	SET @ValidResult = 1
		 	SET @ErrorCode = '1317'
	    	SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
        	SET @LogErrorMessage = RTRIM(@LogErrorMessage) 
		 	RETURN
		 END
		 
	BEGIN TRAN
		 
		 IF @PreparationTableStatus = @InProgress OR @PreparationTableStatus = @Confirm
		 BEGIN
			UPDATE dbo.Partners_WireInPreparation
			SET WireStatus = @Cancel
			WHERE 
			PinNumber = @PinNumber AND 
			PartnerId = @PartnerID			 
		 END
		 
		 IF @PreparationTableStatus = @Release
		 BEGIN
		 
			 EXEC SqlMain.WireTransac.dbo.Partners_WIRE_CancelWire @CurrentLanguageId, @AgSenderCode, @PinNumber, @CancelReasonID, @CancelBy, @PartnerID, @CancelResult OUTPUT, @CancelType	OUTPUT,
			 @ErrorCode OUTPUT, @UserErrorMessage OUTPUT, @LogErrorMessage OUTPUT
			 
			 IF @CancelResult = NULL OR @CancelResult >= 1
			 BEGIN
			 	IF @@tranCount > 0
				ROLLBACK
				
				SET @ValidResult = 1
				RETURN
			 END
		 END
		 
	COMMIT
    END TRY
    BEGIN CATCH
        SET @ValidResult = 1
        SET @ErrorCode = '10950'
	    SET @LogErrorMessage  = ERROR_MESSAGE() 
	    SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
        SET @LogErrorMessage = RTRIM(@LogErrorMessage) 
        IF @@tranCount > 0 
			ROLLBACK
    END CATCH

	RETURN
END


GO

