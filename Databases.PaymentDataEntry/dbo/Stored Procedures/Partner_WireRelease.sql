-- =============================================
-- Author: Marcos Alcantara
-- CreateDate: 2023-09-26
-- Description:	Create a new Wire record, using a pin number to get info from wire preparation table 
-- =============================================
CREATE PROCEDURE [dbo].[Partner_WireRelease]
	@LanguageId INT,
    @PinNumber VARCHAR(20),
    @PartnerId INT,

--OUTPUTs
    @WireId INT OUTPUT,
    @ValidResult INT OUTPUT,-- 0 OK
    @ErrorCode VARCHAR(10) OUTPUT,
    @UserErrorMessage VARCHAR(300) OUTPUT,
    @LogErrorMessage VARCHAR(MAX) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   DECLARE 
        @PreparationID UNIQUEIDENTIFIER, 
        @LSenderId INT,
        @LReceiverId INT,
        @AgSenderId INT,
        @AgSenderCode VARCHAR(10),
        @AgSenderSeq INT,
        @AgSenderState VARCHAR(80),
        @AgSenderCity VARCHAR(80), 
        @AgSenderCountry VARCHAR(80), 
        @AgPayerId INT, 
        @AgPayerCode VARCHAR(10), 
        @DestCountry VARCHAR(80), 
        @DestState VARCHAR(80), 
        @DestCity VARCHAR(80), 
        @BranchId INT, 
        @SenderId INT, 
        @ReceiverId INT, 
        @SenderName VARCHAR(100), 
        @ReceiverName VARCHAR(100),
        @WireStatus VARCHAR(30), 
        @WireDate DATETIME, 
        @WireDatetime DATETIME, 
        @OriAmount MONEY,
        @OriCurrency CHAR(3), 
        @Charges MONEY,
        @OtherChg MONEY,
        @AgencyFee MONEY,
        @OriToDestExRate MONEY, 
        @WireTotalAmount MONEY,
        @DestAmount MONEY,
        @DestCurrency CHAR(3), 
        @AgSenderCommission MONEY,
        @TranTypeID INT, 
        @AccountNumber VARCHAR(30),
        @DeptBankName VARCHAR(60),
        @AccountType INT,
        @DeptAdditionalInfo VARCHAR(60),
        @BankBranchCode VARCHAR(7),
        @DeliveryType CHAR(1), 
        @SourceApp INT, 
        @StsComplianceOk BIT, 
        @StsCancel SMALLINT,
        @WirePurpose VARCHAR(200),
        @FundSource VARCHAR(120),
        @Occupation VARCHAR(80),
        @CustMessage VARCHAR(255),
        @MemberCardSwiped BIT,
        @SndDOB DATETIME,
        @CreatedBy VARCHAR(15), 
        @SndRcvRelationship VARCHAR(80),
        @LoyaltyCardNumber VARCHAR(50),
        @CancelReasonId INT,
        @SndEmployerName VARCHAR(120),
        @SndEmployerPhone VARCHAR(20),
        @TransacTotalAmount INT,
        @RcvIdNumber VARCHAR(80),
        @F1025AgentFullName VARCHAR(150),
        @WireStateFee MONEY,
        @RateTypeID INT, 
        @TeledirectWire BIT,
        @NoFaxBackWire BIT,
        @WireReplacementType SMALLINT,
        @ComputerName VARCHAR(30),
        @PromoCostToCompany MONEY, 
        @OnBehalfId INT = 0,
        @OnBehalfName VARCHAR(100),
        @FXPointsAdded MONEY,
        @FXChangeCost MONEY,
        @FXCostApplyTo CHAR(1),
        @CustTrasactionID INT,
        @PayerPayMethodId INT,
        @FeePlanID INT,
        @FxPlanID INT,
        @AgCommiPlanID INT,
        @FXDif MONEY,
        @FXShare_id INT,
        @SenderIdRecId INT,
        @IncomingPhoneNumber VARCHAR(30),
        @CallerIDVerif BIT,
        @ReplacedControl INT,
        @WaivedCharges MONEY,
        @ReplaceWireRcvSel INT,
        @ReplacementReasonID INT,
        @ExRateMacro SMALLINT,
        @NewTelewire INT,
        @AgComputerId INT,
        @FingerPrint  VARCHAR(200),
        @AppVersion VARCHAR(50),
        @Delay INT,
        @FeeChange MONEY,
        @CostToAgent MONEY,
        @CostToCustomer MONEY,
        @FlexPrcOptionSelected CHAR(1),
        @PayerSecToken INT,
        @WireAvailableDate DATETIME,
        @ClientIP VARCHAR(50),
        @DiscountAmount MONEY,
        @PromoCostToAgent MONEY,
        @PromoCostToPayer MONEY,
        @CRMPromotionId INT,
        @SenderPromoUniqueKey VARCHAR(50),
        @WirePoints INT,
        @WirePointsSign INT,
        @AcumLoyaltyPoints BIT,
        @AgencyExtraFee MONEY,
        @CardChargeId INT,
        @SenderPaymentMethodId INT,
        @WireSenderPaymentMethodFee MONEY,
        @CashBackAmount MONEY,
        @AgPayerRcvIdTypeRecordId INT,
        @WiresAlreadyCountGUID UNIQUEIDENTIFIER,
        @1025AgentFullName VARCHAR(150),
        @AgencyPricingId INT,
        @AgencyPricingDetailId INT,
        @FxBaseId INT,
        @FXPromotionId INT,
        @FxBase MONEY,
        @AgencyFXPointsFromBase MONEY,
        @AgencyPromoFXPoints MONEY,
        @SndPhone VARCHAR(20), 
		@RcvPhone  VARCHAR(20),
        @PartnerAgencyCode VARCHAR(10),
        @WirePreviousStatus VARCHAR(100),
	    @Cancel VARCHAR(100) = 'Cancel',
        @Confirm VARCHAR(100) = 'Confirm',
	    @Release VARCHAR(100) = 'Release'
        
    SET @ValidResult = 0
    SET @WireId = 0
    SET @ErrorCode = ''
    SET @UserErrorMessage = ''
    SET @LogErrorMessage = ''
    IF @WireStateFee IS NULL SET @WireStateFee = 0
    SET @FXPointsAdded = 0
    SET @FXChangeCost = 0
    SET @FXCostApplyTo = ''
    SET @CustTrasactionID = 0
    SET @RateTypeID = 1
    SET @PayerPayMethodId = 1
    SET @IncomingPhoneNumber = ''
    SET @CallerIDVerif = 0
    SET @TeledirectWire = 0
    SET @NoFaxBackWire = 0
    SET @ExRateMacro = 1
    SET @NewTelewire = 0
    SET @FeeChange = 0
    SET @CostToAgent = 0
    SET @CostToCustomer = 0
    SET @FlexPrcOptionSelected = 0
    SET @WireReplacementType = 0
	SET @PromoCostToCompany = 0
    IF @ClientIP IS NULL SET @ClientIP = ''
    IF @AcumLoyaltyPoints IS NULL SET @AcumLoyaltyPoints  = 0
    IF @CardChargeId IS NULL SET @CardChargeId = 0
    IF @SenderPaymentMethodId IS NULL SET @SenderPaymentMethodId = 0
    IF @WireSenderPaymentMethodFee IS NULL SET @WireSenderPaymentMethodFee = 0
    IF @CashBackAmount IS NULL SET @CashBackAmount = ''
    IF @AgPayerRcvIdTypeRecordId IS NULL SET @AgPayerRcvIdTypeRecordId = 0
    IF @ComputerName IS NULL SET @ComputerName = '' 
    
    IF @PinNumber IS NULL OR @PinNumber = ''
	BEGIN
		SET @ValidResult = 1
        SET @ErrorCode = '11472'
	    SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	    SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
		RETURN
	END

    IF @PartnerId IS NULL OR @PartnerId <= 0
	BEGIN
		SET @ErrorCode = '11637'
        SET @ValidResult = 1
	    SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        SET @LogErrorMessage = RTRIM(@LogErrorMessage) 
	    RETURN
	END

    SELECT
        @LSenderId = LSenderId, 
        @LReceiverId = LReceiverId, 
        @AgSenderId = AgSenderId, 
        @AgSenderCode = AgSenderCode, 
        @AgSenderSeq = AgSenderSeq, 
        @AgSenderState = AgSenderState, 
        @AgSenderCity = AgSenderCity, 
        @AgSenderCountry = AgSenderCountry, 
        @AgPayerId = AgPayerId, 
        @AgPayerCode = AgPayerCode, 
        @DestCountry = DestCountry, 
        @DestState = DestState, 
        @DestCity = DestCity, 
        @BranchId = BranchId, 
        @SenderId = SenderId, 
        @ReceiverId = ReceiverId, 
        @SenderName = SenderName, 
        @ReceiverName = ReceiverName, 
        @PinNumber = PinNumber, 
        @WireStatus = WireStatus, 
        @WireDate = WireDate, 
        @WireDatetime = WireDatetime, 
        @OriAmount = OriAmount, 
        @OriCurrency = OriCurrency, 
        @Charges = Charges, 
        @OtherChg = OtherChg, 
        @AgencyFee = AgencyFee, 
        @OriToDestExRate = OriToDestExRate, 
        @WireTotalAmount = WireTotalAmount, 
        @DestAmount = DestAmount, 
        @DestCurrency = DestCurrency, 
        @AgSenderCommission = AgSenderCommission, 
        @TranTypeID = TranTypeID, 
        @AccountNumber = AccountNumber,
        @DeptBankName = DeptBankName,
        @AccountType = AccountType,
        @DeptAdditionalInfo = DeptAdditionalInfo,
        @BankBranchCode = BankBranchCode,
        @DeliveryType = DeliveryType, 
        @SourceApp = SourceApp, 
        @StsComplianceOk = StsComplianceOk, 
        @StsCancel = StsCancel, 
        @WirePurpose = WirePurpose,
        @FundSource = FundSource,
        @Occupation = Occupation,
        @CustMessage = CustMessage,
        @MemberCardSwiped = MemberCardSwiped,
        @SndDOB = SndDOB,
        @CreatedBy = CreatedBy, 
        @SndRcvRelationship = SndRcvRelationship,
        @LoyaltyCardNumber = LoyaltyCardNumber,
        @CancelReasonId = CancelReasonId,
        @SndEmployerName = SndEmployerName,
        @SndEmployerPhone = SndEmployerPhone,
        @TransacTotalAmount = TransacTotalAmount,
        @RcvIdNumber = RcvIdNumber,
        @F1025AgentFullName = F1025AgentFullName,
        @WireStateFee = WireStateFee,
        @PreparationId = PreparationId,
        @PartnerAgencyCode = PartnerAgencyCode
    FROM Partners_WireInPreparation
    WHERE PinNumber = @PinNumber AND PartnerId = @PartnerId;

    IF @LSenderId IS NULL OR @LSenderId = '' OR @LReceiverId IS NULL OR @LReceiverId = ''
    BEGIN
       SET @ErrorCode = '1794'
	   SET @ValidResult      = 1
	   SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	   SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
       RETURN;
    END

    -- Validate Status.
	IF @WireStatus = @Release
	BEGIN
		SET @ValidResult = 1
		SET @ErrorCode = '11762' -- The wire is already released
		SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
		SET @UserErrorMessage =  dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
		RETURN
	END

	IF @WireStatus = @Cancel
	BEGIN
		SET @ValidResult = 1
		SET @ErrorCode = '1317' -- This Wire-Transfer is already canceled.
		SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
		SET @UserErrorMessage =  dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
		RETURN
	END
    BEGIN TRY
        BEGIN TRAN;
            UPDATE Partners_WireInPreparation
                SET WireStatus = @Release
                WHERE PinNumber = @PinNumber;

            INSERT INTO Wires
               (LSenderId ,LReceiverId ,AgSenderId ,AgSenderCode, 
                AgSenderSeq ,AgSenderState ,AgSenderCity ,AgSenderCountry, 
                AgPayerId ,AgPayerCode ,DestCountry ,DestState, 
                DestCity ,BranchId ,SenderId ,OnBehalfId,
                ReceiverId ,SenderName ,OnBehalfName ,ReceiverName,
                PinNumber ,WireDate ,WireDatetime ,OriAmount,
                OriCurrency ,Charges ,OtherChg ,AgencyFee,
                OriToDestExRate, WireStateFee,
                WireTotalAmount ,DestAmount ,DestCurrency ,AgSenderCommission,
                FXPointsAdded,FXChangeCost,FXCostApplyTo,
                TranTypeID ,AccountNumber ,DeptBankName ,AccountType,
                DeptAdditionalInfo ,BankBranchCode ,DeliveryType ,SourceApp,
                StsComplianceOk ,StsCancel ,CustTrasactionID, RateTypeID,PayerPayMethodId,
                FeePlanID, FxPlanID, AgCommiPlanID, FXDif, FXShare_id,
                WirePurpose, FundSource, Occupation, SndEmployerName, SndEmployerPhone, SenderIdRecId,
                IncomingPhoneNumber ,CallerIDVerif ,TeledirectWire ,NoFaxBackWire,
                ReplacedControl ,WaivedCharges, ReplaceWireRcvSel, WireReplacementType ,ReplacementReasonID, 
                MemberCardSwiped ,CreatedBy ,ComputerName, CustMessage, ExRateMacro, SndDOB,SndRcvRelationship,
                NewTelewire, AgComputerid, ComputerId, AppVersion, TkDelay, FeeChange, CostToAgent ,CostToCustomer,
                FlexPrcOptionSelected, PayerSecToken, WireAvailableDate, ClientIP,
                DiscountAmount, PromoCostToCompany, PromoCostToAgent, PromoCostToPayer, CRMPromotionId, SenderPromoUniqueKey,
                LoyaltyCardNumber, WirePoints, WirePointsSign, AcumLoyaltyPoints, AgencyExtraFee,
			    CardChargeId, SenderPaymentMethodId, WireSenderPaymentMethodFee, CashBackAmount, TransacTotalAmount,
			    AgPayerRcvIdTypeRecordId, RcvIdNumber,WiresAlreadyCountGUID,F1025AgentFullName, AgencyPricingId,
			    AgencyPricingDetailId, FxBaseId, FXPromotionId, FxBase, AgencyFXPointsFromBase, AgencyPromoFXPoints, PartnerAgencyCode, PartnerId)
            VALUES
               (@LSenderID, @LReceiverID, @AgSenderId, @AgSenderCode,
                @AgSenderSeq, @AgSenderState, @AgSenderCity, @AgSenderCountry,
                @AgPayerId, @AgPayerCode, @DestCountry, @DestState,
                @DestCity, @BranchId, @SenderId, @OnBehalfId,
                @ReceiverId, @SenderName, @OnBehalfName, @ReceiverName,
                @PinNumber, @WireDate, @WireDatetime, @OriAmount,
                @OriCurrency, @Charges, @OtherChg, @AgencyFee,
                @OriToDestExRate, @WireStateFee,
                @WireTotalAmount, @DestAmount, @DestCurrency, @AgSenderCommission,
                @FXPointsAdded, @FXChangeCost, @FXCostApplyTo,
                @TranTypeID, @AccountNumber, @DeptBankName, @AccountType,
                @DeptAdditionalInfo, @BankBranchCode, @DeliveryType, @SourceApp,
                @StsComplianceOk, @StsCancel, @CustTrasactionID, @RateTypeID, @PayerPayMethodId,
                @FeePlanID, @FxPlanID, @AgCommiPlanID, @FXDif, @FXShare_id, 
                @WirePurpose, @FundSource, @Occupation, @SndEmployerName, @SndEmployerPhone, @SenderIdRecId,
                @IncomingPhoneNumber, @CallerIDVerif, @TeledirectWire, @NoFaxBackWire,
                @ReplacedControl, @WaivedCharges, @ReplaceWireRcvSel, @WireReplacementType, @ReplacementReasonID,
                @MemberCardSwiped, @CreatedBy, @ComputerName, @CustMessage, @ExRateMacro, @SndDOB,@SndRcvRelationship,
                @NewTelewire, @AgComputerId, @FingerPrint, @AppVersion, @Delay, @FeeChange, @CostToAgent , @CostToCustomer,
                @FlexPrcOptionSelected, @PayerSecToken, @WireAvailableDate, @ClientIP,
                @DiscountAmount, @PromoCostToCompany, @PromoCostToAgent, @PromoCostToPayer, @CRMPromotionId, @SenderPromoUniqueKey,
                @LoyaltyCardNumber, @WirePoints, @WirePointsSign, @AcumLoyaltyPoints, @AgencyExtraFee,
			    @CardChargeId, @SenderPaymentMethodId, @WireSenderPaymentMethodFee, @CashBackAmount, @WireTotalAmount,
			    @AgPayerRcvIdTypeRecordId, ISNULL(@RcvIdNumber,0), @WiresAlreadyCountGUID, @1025AgentFullName,
			    @AgencyPricingId, @AgencyPricingDetailId, @FxBaseId, @FXPromotionId, @FxBase, @AgencyFXPointsFromBase, 
			    @AgencyPromoFXPoints, @PartnerAgencyCode, @PartnerId)

            SELECT @WireId = SCOPE_IDENTITY()

            IF @StsComplianceOk = 0
			BEGIN
			  UPDATE WireCompliance.dbo.Comp_WireOnHold WITH(UPDLOCK) SET WireId = @WireId
			  WHERE GuidId = @PreparationId

			  UPDATE WireCompliance.dbo.LogAmountWarnMsg WITH(UPDLOCK) SET Wire_ID = @WireId
			  WHERE CompGuidId = @PreparationId
			END

			IF EXISTS (Select * FROM WireCompliance.dbo.Comp_WiresOnIRSHold Where GuidId  = @PreparationId)
			BEGIN
			  UPDATE WireCompliance.dbo.Comp_WiresOnIRSHold with(updlock) Set WireId = @WireId
			   WHERE GuidId = @PreparationId
			END

			SELECT @SndPhone = SndPhone FROM dbo.Senders Where LSenderId = @LSenderID
			SELECT @RcvPhone = RcvPhone FROM dbo.Receivers Where LReceiverID = @LReceiverID
 
			EXEC WireCompliance.dbo.spi_Create_CumulativeSummaryAmountsToday_DestCurrency
				@WireId,
				@OriAmount, @DestAmount,
				@SenderName, @OriCurrency, 
				@AgSenderCountry, @AgSenderState, @AgSenderCity,
				@ReceiverName, @DestCurrency,
				@DestCountry, @DestState, @DestCity,
				@SndPhone, @RcvPhone,
				@DeptBankName, @AccountNumber, @AgPayerCode

			INSERT INTO ProcessedWires with(rowlock) (WireID, Done) Values(@WireId, 0)

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SET @ValidResult  = 500
        SET @ErrorCode = '10950'
        SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@LanguageId)
        SET @LogErrorMessage  = ERROR_MESSAGE()

    END CATCH;

    RETURN;
END
