/*
=============================================
Author: Borelli Elias
Create date: 2023-09-26
Description: A record will be created in Preparation Table.
=============================================
*/
CREATE PROCEDURE dbo.Partners_CreateWireInPreparation
	@AccountNumber Varchar(30) = NULL,
	@AccountType INT = NULL,
	--Agencies
	@AgPayerId INT,
	@AgSenderCity Varchar(60),
	@AgSenderCommission MONEY,
	@AgSenderCountry Varchar(80),
	@AgSenderCode Varchar(10),
	@AgSenderState Varchar(40),
	@BankBranchCode INT = NULL,
	@BranchId INT,
	@Charges MONEY,
	@Cpf Varchar(11) = NULL,
	@CreatedBy Varchar(15),
	@CustMessage Varchar(255) = NULL,
	@DeliveryType Char(1) = NULL,
	@DeptBankName Varchar(60) = NULL,
	--Payer
	@DestAmount MONEY,
	@DestCity Varchar(60),
	@DestCountry Varchar(80),           
	@DestCurrency Char(3),         
	@DestState Varchar(40),            
	@FundSource Varchar(120) = NULL,           
	@IsCellPhone Bit,           
	@MessageToRcv Varchar(255) = NULL,         
	@Occupation Varchar(80) = NULL,           
	@OriAmount MONEY,            
	@OriCurrency Char(3),          
	@OriToDestExRate MONEY,      
	@PreparationID UNIQUEIDENTIFIER,        
	--Receivers
	@RcvAddress Varchar(200),
	@RcvCity Varchar(60),                          
	@RcvCountry Varchar(80),           
	@RcvFirstName Varchar(50),          
	@RcvLast1 Varchar(50),             
	@RcvLast2 Varchar(50) = NULL,             
	@RcvPhone Varchar(20),             
	@RcvState Varchar(40),              
	@RcvZip Varchar(15),               
	@ReceiverId INT, 
	--Senders          
	@SenderId INT,             
	@SndAddress Varchar(50),           
	@SndCity Varchar(60),              
	@SndCountry Varchar(80),            
	@SndFirstName Varchar(50),         
	@SndLast1 Varchar(50),             
	@SndLast2 Varchar(50) = NULL,             
	@SndPhone Varchar(20),             
	@SndState Varchar(40),             
	@SndZip Varchar(15),               
	@TranTypeID INT,          
	@WirePurpose VARCHAR(200) = NULL,          
	@WireStateFee MONEY,         
	@WireTotalAmount MONEY, 
	@CurrentLanguageId INT, 
	@PartnerId INT,
    --OUTPUTS
    @StsComplianceOk BIT OUTPUT ,   -- 0 si tiene HITS; 1 si no los tiene
	@Print1025 BIT OUTPUT,   -- Agency to Request the form 1025 to the sender 
	@RequireSndDOB BIT OUTPUT, -- Agency to Request Sender's date of birth
	@RequireRcvDOB BIT OUTPUT,    -- Agency to Request Receiver's date of birth
	@RequireWireAddInf BIT OUTPUT,   -- Agency to Request Wire additional information,  
	@RequirePhotoID BIT OUTPUT,  -- Agency to Request Sender's photo ID
	@RequireSS BIT OUTPUT, -- Agency to Request Sender's Social security Number  
	@RequireIncomeVerif BIT OUTPUT,   -- Agency to Request Sender's Income Verification Number 
	@RequireEmploymentInfo BIT OUTPUT,  -- Agency to Request Sender's Employment Information 
	@PayerIDRequirementMsgToShow varchar(500) OUTPUT,   
	@1025WithoutSign bit = 0 OUTPUT,  -- Agency to Request Sender's  1025 wothout sign 
	@RequiredNationality bit = 0 OUTPUT, -- Agency to Request Sender's  Nationality info 
	@HitByOfacFilter bit = 0 OUTPUT, -- indicates if the sender is in Ofac list 
    @WireResult INT OUTPUT, 
    @ValidResult INT OUTPUT, 
    @ErrorCode varchar(10) OUTPUT,
    @LogErrorMessage VARCHAR(300) OUTPUT,
	@FocusFieldName VARCHAR(300) OUTPUT,
    @UserErrorMessage VARCHAR(300) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON
    BEGIN TRY

        DECLARE @Electronic1025  BIT  -- Agency to Request the form 1025 in electronic format to the sender
        DECLARE @RequirePhotoIdImage BIT -- Agency to Request Sender's photo Image
		DECLARE @SenderPhotoIdOnFile BIT -- Agency to Request Sender's photo on file 
        SET @WireResult = 0
        DECLARE @LSenderId INT = 0
        DECLARE @LReceiverId INT = 0
        DECLARE @AgSenderId INT = 0
        DECLARE @ReceiverGroupId INT = 0
        DECLARE @SenderGroupId INT = 0
        DECLARE @SndLastVersionId INT = 0
		DECLARE @SndNoSecLastName BIT = 0
		DECLARE @RcvNoSecLastName BIT = 0
		DECLARE @RcvLastVersionID INT = 0
        DECLARE @SndCountryDescription VARCHAR(MAX) = '' 
		DECLARE @SndStateDescription VARCHAR(MAX) = '' 
		DECLARE @SndCityDescription VARCHAR(MAX) = ''
		DECLARE @RcvCountryDescription VARCHAR(MAX) = '' 
		DECLARE @RcvStateDescription VARCHAR(MAX) = '' 
		DECLARE @RcvCityDescription VARCHAR(MAX) = ''
		DECLARE @AgSenderCountryDescription VARCHAR(MAX) = ''
		DECLARE @AgSenderStateDescription VARCHAR(MAX) = '' 
		DECLARE @AgSenderCityDescription VARCHAR(MAX) = ''
		DECLARE @DestCountryDescription VARCHAR(MAX) = '' 
		DECLARE @DestStateDescription VARCHAR(MAX) = ''
		DECLARE @DestCityDescription VARCHAR(MAX) = ''
		DECLARE @SenderIDFromHost INT = 0
		DECLARE @ReceiverIDFromHost INT = 0
		DECLARE @SenderPartnerID INT = 0
		DECLARE @ReceiverPartnerID INT = 0
		DECLARE @SndFullName varchar(150)
  		DECLARE @RcvFullName varchar(150)
  		DECLARE @AgPayerCode VARCHAR(10) = ''
		DECLARE @SndVersionId INT
		DECLARE @RcvVersionId INT
		DECLARE @PartnerAgencyCode Varchar(10)
		DECLARE @AgSenderSeq INT
		DECLARE @AgStateAbbr NVARCHAR(10)
		DECLARE @BrName NVARCHAR(40)
    	DECLARE @BrPlaceName NVARCHAR(40)
    	DECLARE @BrCountry NVARCHAR(30)
    	DECLARE @BrCity NVARCHAR(40)
    	DECLARE @BrState NVARCHAR(30)
		DECLARE @HostAction NVARCHAR(10)
		DECLARE @WireDate DATETIME
		DECLARE @AgPayerIdHost INT
		DECLARE @CashPickUP INT = 1
		DECLARE @BankDeposit INT = 3
		
	    -- Validar TranTypeID
		IF (@TranTypeID IS NULL OR (@TranTypeID <> @CashPickUP AND @TranTypeID <> @BankDeposit))
		BEGIN
			SET @WireResult = 1
			SET @ErrorCode = '10820' -- Please Select Pick Up or Bank Deposit 
			SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, @CurrentLanguageId)
			RETURN
		END
				
      	 IF isnull(@RcvLast2,'') = ''
	     BEGIN
		   SET @RcvNoSecLastName =1
		   SET @RcvLast2 = ''
		 END
			 
		 IF isnull(@SndLast2,'') = ''
	     BEGIN
		   SET @SndNoSecLastName =1
		   SET @SndLast2 = ''
		 END
		 		 
		-- Validate agPayerId
		IF (@AgPayerId IS NULL OR @AgPayerId <= 0)
			BEGIN
				SET @WireResult = 1
				SET @ErrorCode = '11757' -- PayerID es empty. Enter a value.
				SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode, @CurrentLanguageId)
				SET @LogErrorMessage = RTRIM(@LogErrorMessage)
				RETURN
			END

		 IF @PartnerId IS NULL OR @PartnerId <= 0
		 	BEGIN
				SET @WireResult = 1
		 	    SET @ErrorCode = '11637'
	    		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
        		SET @LogErrorMessage = RTRIM(@LogErrorMessage)
		 	RETURN
		 END
		 
		 IF @SenderId IS NULL OR @SenderId <= 0
		 	BEGIN
				SET @WireResult = 1
		 	    SET @ErrorCode = '11752'
	    		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
        		SET @LogErrorMessage = RTRIM(@LogErrorMessage) 
		 	RETURN
		 END
		 
		 IF @ReceiverId IS NULL OR @ReceiverId <= 0
		 	BEGIN
				SET @WireResult = 1
		 	    SET @ErrorCode = '11340'
	    		SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
        		SET @LogErrorMessage = RTRIM(@LogErrorMessage) 
		 	RETURN
		 END
		 
		 
		--Sender Validation
		EXEC dbo.Wires_Validate_Sender @SndAddress,	@SndCity, @SndCountry, @SndFirstName, @SndLast1, @SndPhone, @SndState, @SndZip, 
									@ValidResult = @ValidResult OUTPUT, @ErrorCode = @ErrorCode OUTPUT, @FocusFieldName = @FocusFieldName OUTPUT 

		IF @ValidResult = 1
		BEGIN
			  SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	          SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
	    RETURN
	    END
	    
	    --Receiver Validation
	    EXEC dbo.Wires_Validate_Receiver @RcvAddress, @RcvCity, @RcvCountry, @RcvFirstName, @RcvLast1, @RcvState, @ValidResult = @ValidResult OUTPUT, @ErrorCode = @ErrorCode OUTPUT, @FocusFieldName = @FocusFieldName OUTPUT 
	    
        IF @ValidResult = 1
		BEGIN
			  SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	          SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
	    RETURN
	    END
        
		BEGIN TRAN
		
		EXEC Wiresearch.dbo.GetCountry_State_City_Translations 
			@SndCountry, 
			@SndState, 
			@SndCity, 
			@RcvCountry,
			@RcvState, 
			@RcvCity, 
			@AgSenderCountry, 
			@AgSenderState, 
			@AgSenderCity,
			@DestCountry, 
			@DestState, 
			@DestCity, 
			@CurrentLanguageId,  
			@PartnerId,
		    @WireResult = @WireResult OUTPUT, 
		    @ValidResult = @ValidResult OUTPUT, 
		    @ErrorCode = @ErrorCode OUTPUT, 
		    @LogErrorMessage = @LogErrorMessage OUTPUT, 
		    @FocusFieldName = @FocusFieldName OUTPUT, 
		    @UserErrorMessage = @UserErrorMessage OUTPUT, 
		    @SndCountryDescriptionResult = @SndCountryDescription OUTPUT, 
		    @SndStateDescriptionResult = @SndStateDescription OUTPUT, 
		    @SndCityDescriptionResult = @SndCityDescription OUTPUT,
			@RcvCountryDescriptionResult = @RcvCountryDescription OUTPUT, 
			@RcvStateDescriptionResult = @RcvStateDescription OUTPUT, 
			@RcvCityDescriptionResult = @RcvCityDescription OUTPUT,
			@AgSenderCountryDescriptionResult = @AgSenderCountryDescription OUTPUT, 
			@AgSenderStateDescriptionResult = @AgSenderStateDescription OUTPUT, 
			@AgSenderCityDescriptionResult = @AgSenderCityDescription OUTPUT,
			@DestCountryDescriptionResult = @DestCountryDescription OUTPUT, 
			@DestStateDescriptionResult = @DestStateDescription OUTPUT, 
			@DestCityDescriptionResult = @DestCityDescription OUTPUT;
		
		IF @ValidResult = 1 OR @WireResult = 1
		BEGIN
		    IF @@tranCount > 0
			ROLLBACK
			RETURN
		END
			
		--Check Sender
		SET @SndPhone = dbo.justnum(@SndPhone)
		SELECT @SndFirstName = [dbo].[CleanWhiteSpaces](@SndFirstName)
		SELECT @SndLast1 = [dbo].[CleanWhiteSpaces](@SndLast1)
		SELECT @SndLast2 = [dbo].[CleanWhiteSpaces](@SndLast2)
			
		SET @SndFullName =rtrim(@SndFirstName+' '+@SndLast1+' '+@SndLast2)
		
		SELECT 
			@SenderPartnerID = isnull(SenderPartnerID,0), 
			@SenderIDFromHost = isnull(SenderID,0), 
			@SndLastVersionId = isnull(SndLastVersionId,0), 
			@SenderGroupId = isnull(SenderGroupId,0) 
		FROM SenderPartner with(nolock) 
		WHERE 
			SenderPartnerID = ISNULL(@SenderId,0) AND Partner = @PartnerId
		
		INSERT INTO Senders with(rowlock) 
	 	    (SenderId, SenderGroupId, SndFullName, SndFirstName, SndLast1, SndLast2, 
			  SndAddress, SndCountry, SndState, SndCity, SndZip,
			  SndPhone, SndLastVersionId, SndNoSecLastName, 
			  SndIdTypeName, SndIdNumber, SndIdCountry, SndIdState, SndIdExpirationDate,
			  IsCellPhone, OptStatus, OptStatusDate,OptStatusPromo, Citizenship)
		VALUES
		     (@SenderIDFromHost, @SenderGroupId, @SndFullName, @SndFirstName, @SndLast1, @SndLast2, 
			  @SndAddress, @SndCountryDescription, @SndStateDescription, @SndCityDescription, @SndZip,
			  @SndPhone, @SndLastVersionId, @SndNoSecLastName, '', '', '', '', NULL, ISNULL(@IsCellPhone,0), '', CAST(GETDATE() as Date),'', NULL)

		SET @LSenderId = SCOPE_IDENTITY();
		
		IF @SenderPartnerID IS NULL OR @SenderPartnerID = 0 
		BEGIN
			INSERT INTO SenderPartner with(rowlock) (SenderPartnerID, LSenderID, SenderID, SndLastVersionId, SenderGroupId, Partner) VALUES (@SenderId, @LSenderId, @SenderIDFromHost, @SndLastVersionId, @SenderGroupId, @PartnerId )
		END
		ELSE
		BEGIN
			UPDATE SenderPartner with(rowlock) SET LSenderID = @LSenderId WHERE SenderPartnerID = @SenderId AND Partner = @PartnerId
		END
		
		--Check Partner
		SET @RcvPhone = dbo.justnum(@RcvPhone)	  
		SELECT @RcvFirstName = [dbo].[CleanWhiteSpaces](@RcvFirstName)
		SELECT @RcvLast1 = [dbo].[CleanWhiteSpaces](@RcvLast1)
		SELECT @RcvLast2 = [dbo].[CleanWhiteSpaces](@RcvLast2)
			
		SET @RcvFullName =rtrim(@RcvFirstName+' '+@RcvLast1+' '+@RcvLast2)
		
		SELECT 
			@ReceiverPartnerID = isnull(ReceiverPartnerID,0), 
			@ReceiverIDFromHost = isnull(ReceiverID,0), 
			@RcvLastVersionId = isnull(RcvLastVersionId,0), 
			@ReceiverGroupId = isnull(ReceiverGroupId,0) 
		FROM ReceiverPartner WITH(nolock) 
		WHERE 
			ReceiverPartnerID = ISNULL(@ReceiverId,0) AND Partner = @PartnerId
		
		
		INSERT INTO Receivers with(rowlock)
	  	   (ReceiverId, ReceiverGroupId, RcvFullName, RcvFirstName,
		    RcvLast1, RcvLast2, RcvAddress, RcvCountry,
		    RcvState, RcvCity, RcvZip, RcvPhone,
		    RcvNoSecLastName, RcvLastVersionID, CPF, Entered, RcvDOB)
		VALUES
	  	    (@ReceiverIDFromHost, @ReceiverGroupId, @RcvFullName, @RcvFirstName,
		    @RcvLast1, @RcvLast2, @RcvAddress, @RcvCountryDescription,
		    @RcvStateDescription, @RcvCityDescription, @RcvZip, @RcvPhone,
		    @RcvNoSecLastName, @RcvLastVersionID, ISNULL(@Cpf,''), GETDATE(), NULL)
		
		SET @LReceiverId = SCOPE_IDENTITY();			      
		
		IF @ReceiverPartnerID IS NULL OR @ReceiverPartnerID = 0
		BEGIN
			 INSERT INTO ReceiverPartner with(rowlock) (ReceiverPartnerID, LReceiverID, ReceiverID, RcvLastVersionId, ReceiverGroupId, Partner) VALUES (@ReceiverId, @LReceiverId, @ReceiverIDFromHost, @RcvLastVersionId, @ReceiverGroupId, @PartnerId) 
		END
		ELSE
		BEGIN
			 UPDATE ReceiverPartner with(rowlock) 
			 SET LReceiverID = @LReceiverId 
			 WHERE ReceiverPartnerID = @ReceiverId AND Partner = @PartnerId
		END
		
		SET @PartnerAgencyCode = @AgSenderCode
		SET @AgSenderCode = 'NAC-0001'
		
		SELECT 
		@AgSenderId = AgencyId 
		FROM Wiresearch.dbo.Agencies 
		WHERE AgencyCode = @AgSenderCode;
		
		SELECT 
		@AgPayerIdHost = PayerID 
		FROM Wiresearch.dbo.PayerPartner 
		WHERE PayerPartnerID = @AgPayerId AND 
		Partner = @PartnerId AND 
		TransactionType = @TranTypeID

		IF @AgPayerIdHost IS NULL or @AgPayerIdHost = 0
		BEGIN
			IF @@tranCount > 0
			BEGIN
				ROLLBACK;
			END
			SET @WireResult = 1
			SET @ErrorCode = '1662'
			SET @LogErrorMessage  = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,1)
	        SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
			RETURN
		END
		
		SELECT 
		@AgPayerCode = AgencyCode 
		FROM Wiresearch.dbo.Agencies 
		WHERE AgencyId = @AgPayerIdHost 
		

		SELECT 
		TOP 1 
		@BranchId = ISNULL(BranchID,0) 
		FROM Wiresearch.dbo.branches 
		WHERE 
		AgencyCode = @AgPayerCode and 
		UPPER(LTRIM(RTRIM(BrCity))) = UPPER(LTRIM(RTRIM(@DestCityDescription))) and 
		UPPER(LTRIM(RTRIM(BrState))) = UPPER(LTRIM(RTRIM(@DestStateDescription)))

		-- Validate Required Fields
		exec [dbo].[PartnersWire_Validate_RequiredFields]
		@PreparationId,
		@AgPayerIdHost,
		@BranchId,
		@PartnerId,
		@Charges,
		@CreatedBy,
		@DestAmount,
		@DestCurrency,
		@OriAmount,
		@OriToDestExRate,
		@TranTypeID,
		@CurrentLanguageId,
		@AccountNumber,
		@OriCurrency,
		@WireTotalAmount,
		@DeptBankName,
		@AccountType,
		@BankBranchCode,
		@AgSenderCountryDescription,
		@DestCountryDescription,
		@AgPayerCode,
		@WireStateFee,
		@ValidResult OUTPUT, -- SET RESULT FROM VALIDATIONS
		@ErrorCode OUTPUT, -- SET @ErrorCode FROM VALIDATIONS
		@UserErrorMessage OUTPUT -- SET @UserErrorMessage FROM VALIDATIONS

		IF @ValidResult IS NULL OR @ValidResult > 0
		BEGIN
			-- If validation are not OK (RESULT > 0) rollback transaction and return ERROR MESSAGE
			IF @@tranCount > 0
			BEGIN
				ROLLBACK;
			END

			SET @WireResult = 1
			SET @LogErrorMessage = ERROR_MESSAGE()
			RETURN
		END
		
		--Payer validations.
		EXEC Wiresearch.dbo.WebAgent_ValidPayerBranchTransactionDelMethodDestCurrency
				@CurrentLanguageId,	@AgSenderCode, @AgPayerCode, @AgPayerIdHost, @BranchId, @TranTypeID, @DeliveryType,	@DestCurrency,
			    @ValidResult OUTPUT, @ErrorCode OUTPUT, @LogErrorMessage OUTPUT, @UserErrorMessage OUTPUT

		IF @ValidResult >= 1
		BEGIN
		    IF @@tranCount > 0
			ROLLBACK
			RETURN
		END

		---Agency Sequence Number  
		exec WireKeys.dbo.sps_GenAgencySeq @AgSenderCode, @AgSenderSeq output  

		IF @TranTypeID = 3
		BEGIN
		
			SELECT
			@AgStateAbbr = gs.StateAbbr
			FROM Wiresearch.dbo.Geo_States gs
			INNER JOIN Wiresearch.dbo.Geo_Countries gc ON gc.CountryAbbr = gs.CountryAbbr
			WHERE gs.StateName = @AgSenderStateDescription AND gc.CountryName = @AgSenderCountryDescription
			
			SELECT 
			TOP 1
			@BrName = BrName,
	    	@BrPlaceName = BrPlaceName,
	    	@BrCountry = BrCountry,
	    	@BrCity = BrCity,
	    	@BrState = BrState
			FROM Wiresearch.dbo.branches 
			WHERE BranchID = @BranchId
		
			SET @WireDate = dbo.DateOnly(GETDATE())
			EXEC Wiresearch.dbo.AgPayers_ValidateAccount @AgSenderCode, @AgPayerCode, @TranTypeID, @WireDate, @AccountNumber, @AccountType, @DeptBankName,
				@SndFirstName, @SndLast1, @SndLast2, @SndAddress, @RcvFirstName, @RcvLast1, @RcvLast2, @AgSenderStateDescription, @AgStateAbbr, @AgSenderCityDescription, @SndZip,
				@AgSenderCountryDescription, @OriCurrency, @DestCountryDescription, @DestCurrency, @BrName, @BrPlaceName, @BrCountry, @BrCity, @BrState, @OriAmount, @DestAmount, @OriToDestExRate,
				@CurrentLanguageId, @IsValid = @ValidResult OUTPUT, @HostAction = @HostAction OUTPUT, @ErrorCode = @ErrorCode OUTPUT, @ErrorMessage = @UserErrorMessage OUTPUT
		
			IF @ValidResult = 0 AND @HostAction = 'ERROR' 
			BEGIN
				IF @@tranCount > 0
				BEGIN
					ROLLBACK;
				END

			SET @WireResult = 1
			SET @LogErrorMessage = @UserErrorMessage
			RETURN
			
			END	
		END	

		IF EXISTS (SELECT 1 FROM dbo.Partners_WireInPreparation with(rowlock) WHERE PreparationID = @PreparationID AND PartnerId = @PartnerId)
			BEGIN
				DECLARE @currentStatus VARCHAR(30)

				SET @currentStatus = (SELECT WireStatus FROM dbo.Partners_WireInPreparation with(rowlock) WHERE PreparationID = @PreparationID AND PartnerId = @PartnerId)

				IF(@currentStatus = 'Confirm' OR @currentStatus = 'Release' OR @currentStatus = 'Cancel')
					BEGIN
						SET @ErrorCode = '10211'
						SET @ValidResult = 1
						SET @LogErrorMessage = ''
						SET @UserErrorMessage = dbo.fnc_EcoMessage_withLanguage (@ErrorCode,@CurrentLanguageId)
						ROLLBACK
						RETURN
					END
				ELSE
					BEGIN
						UPDATE dbo.Partners_WireInPreparation SET 
						PartnerAgencyCode = @PartnerAgencyCode,
						AgSenderId = @AgSenderId,
						AgSenderCode = @AgSenderCode, 
						AgSenderSeq = @AgSenderSeq, 
						AgSenderState = @AgSenderStateDescription, 
						AgSenderCity = @AgSenderCityDescription, 
						AgSenderCountry = @AgSenderCountryDescription, 
						AgPayerId = @AgPayerIdHost,
						AgPayerCode = @AgPayerCode, 
						DestCountry = @DestCountryDescription, 
						DestState = @DestStateDescription, 
						DestCity = @DestCityDescription, 
						BranchId = @BranchId, 
						LSenderId = @LSenderId, 
						LReceiverId = @LReceiverId, 
						SenderId = @SenderIDFromHost, 
						ReceiverId = @ReceiverIDFromHost, 
						SenderName = @SndFullName, 
						ReceiverName = @RcvFullName, 
						PinNumber = NULL, 
						WireStatus = 'In Process', 
						WireDate = dbo.DateOnly(GETDATE()), 
						WireDatetime = GETDATE(), 
						OriAmount = ISNULL(@OriAmount,0), 
						OriCurrency = ISNULL(@OriCurrency,''),
						Charges = ISNULL(@Charges,0),
						OtherChg = 0, 
						AgencyFee = 0, 
						OriToDestExRate = ISNULL(@OriToDestExRate,0), 
						WireStateFee = ISNULL(@WireStateFee,0), 
						WireTotalAmount = ISNULL(@WireTotalAmount,0), 
						DestAmount = ISNULL(@DestAmount,0), 
						DestCurrency = ISNULL(@DestCurrency,''), 
						AgSenderCommission = ISNULL(@AgSenderCommission,0), 
						TranTypeID = ISNULL(@TranTypeID,0), 
						AccountNumber = ISNULL(@AccountNumber,''), 
						DeptBankName = ISNULL(@DeptBankName,''), 
						AccountType = ISNULL(@AccountType,0), 
						DeptAdditionalInfo = '', 
						BankBranchCode = ISNULL(@BankBranchCode,''), 
						DeliveryType =  ISNULL(@DeliveryType,0), 
						SourceApp = 46, 
						StsComplianceOk = 0, 
						StsCancel = 0, 
						WirePurpose = @WirePurpose, 
						FundSource = @FundSource, 
						Occupation = @Occupation, 
						CustMessage = @CustMessage, 
						MemberCardSwiped = null, 
						SndDOB = null,
						CreatedBy = @CreatedBy, 
						SndRcvRelationship = '', 
						LoyaltyCardNumber = '', 
						CancelReasonId = 0, 
						SndEmployerName = '', 
						SndEmployerPhone = '', 
						TransacTotalAmount = ISNULL(@WireTotalAmount,0), 
						PartnerId = @PartnerId, 
						RcvIdNumber = '', 
						F1025AgentFullName = '', 
						CPF = ISNULL(@Cpf,'')
						WHERE PreparationID = @PreparationID AND PartnerId = @PartnerId
					END
			END
		ELSE
			BEGIN
				INSERT INTO dbo.Partners_WireInPreparation with(rowlock) (PreparationID, PartnerAgencyCode, AgSenderId, AgSenderCode, AgSenderSeq, AgSenderState, AgSenderCity, AgSenderCountry, AgPayerId
					, AgPayerCode, DestCountry, DestState, DestCity, BranchId, LSenderId, LReceiverId, SenderId, ReceiverId, SenderName, ReceiverName, PinNumber, WireStatus, WireDate, WireDatetime, OriAmount, OriCurrency
					, Charges, OtherChg, AgencyFee, OriToDestExRate, WireStateFee, WireTotalAmount, DestAmount, DestCurrency, AgSenderCommission, TranTypeID, AccountNumber, DeptBankName, AccountType
					, DeptAdditionalInfo, BankBranchCode, DeliveryType, SourceApp, StsComplianceOk, StsCancel, WirePurpose, FundSource, Occupation, CustMessage, MemberCardSwiped, SndDOB
					, CreatedBy, SndRcvRelationship, LoyaltyCardNumber, CancelReasonId, SndEmployerName, SndEmployerPhone, TransacTotalAmount, PartnerId, RcvIdNumber, F1025AgentFullName, CPF)
				VALUES
				(@PreparationID, @PartnerAgencyCode, @AgSenderId, @AgSenderCode, @AgSenderSeq, @AgSenderStateDescription, @AgSenderCityDescription, @AgSenderCountryDescription, @AgPayerIdHost
				, @AgPayerCode, @DestCountryDescription, @DestStateDescription, @DestCityDescription, @BranchId, @LSenderId, @LReceiverId, @SenderIDFromHost, @ReceiverIDFromHost, @SndFullName, @RcvFullName, NULL, 'In Process'
				, dbo.DateOnly(GETDATE()), GETDATE(), ISNULL(@OriAmount,0), ISNULL(@OriCurrency,''), ISNULL(@Charges,0), 0, 0, ISNULL(@OriToDestExRate,0), ISNULL(@WireStateFee,0), ISNULL(@WireTotalAmount,0), ISNULL(@DestAmount,0)
				, ISNULL(@DestCurrency,''), ISNULL(@AgSenderCommission,0), ISNULL(@TranTypeID,0), ISNULL(@AccountNumber,''), ISNULL(@DeptBankName,''), ISNULL(@AccountType,0), '', ISNULL(@BankBranchCode,''), ISNULL(@DeliveryType,0)
				, 46, 0, 0, @WirePurpose, @FundSource, @Occupation, @CustMessage, NULL, NULL, @CreatedBy, '', '', 0, '', '', ISNULL(@WireTotalAmount,0), @PartnerId, '', '', ISNULL(@Cpf,''))
			END
		

		DECLARE @ComplianceHitsFound BIT,  @SndDOB DATETIME,
				@RcvDOB DATETIME,
				@AgPayerIdRequirementId INT  = 0, @PhotoIdInfo VARCHAR(100), @PhotoIdRecordId INT,
				@UnVerifiedIdOnFile BIT = 0,  @UnVerifiedIdType VARCHAR(5)='',  @UnVerifiedIdNumber VARCHAR(80)='',  
				@UnVerifiedIdExpDate DATETIME,  @UnVerifiedIdCountryAbbr VARCHAR(5)='',  @UnVerifiedIdStateId INT=0,  @UnVerifiedimageloc VARCHAR(250)='',
				@AllowCompleteTransaction BIT = 0,  @RequestedByPayer BIT = 0

		--COMPLIANCE CHECK
		EXEC [Wiresearch].[dbo].[Partners_WIRE_ComplianceCheck_SndDOB_V3]
			@PreparationId, @CurrentLanguageId, @AgSenderCode, @AgSenderStateDescription,  @AgSenderCityDescription, @SenderIDFromHost OUTPUT, @SndVersionId OUTPUT, @sndFirstName, @sndLast1, @sndLast2, 
			@SndAddress, @SndCountryDescription, @SndStateDescription, @SndCityDescription, @SndZip, @SndPhone, @SenderGroupId OUTPUT, @CreatedBy, @ReceiverIDFromHost OUTPUT, @deptBankName, @accountNumber, @agPayerCode, @destCountry, @destState, 
			@destCity, @oriAmount, @oriCurrency, @WireTotalAmount,  @tranTypeId,   @RcvPhone,    @rcvFirstName,   @rcvLast1,   @rcvLast2, @RcvCountryDescription, @RcvStateDescription, @RcvCityDescription, 
			@Cpf, @RcvAddress, @RcvZip, @ReceiverGroupId OUTPUT, @RcvVersionId OUTPUT,  1,  'N',  0, 0,  
		    @ValidResult OUTPUT,  @ErrorCode OUTPUT,  @UserErrorMessage OUTPUT,  @LogErrorMessage OUTPUT,  @StsComplianceOk OUTPUT,  @Print1025 OUTPUT,  @Electronic1025  OUTPUT,   
			@ComplianceHitsFound OUTPUT,  @RequireSndDOB OUTPUT,  @SndDOB OUTPUT,  @RequireRcvDOB OUTPUT,  @RcvDOB OUTPUT, @RequireWireAddInf OUTPUT,  @RequirePhotoID OUTPUT,  @RequireSS OUTPUT,  
			@RequireIncomeVerif OUTPUT,  @RequireEmploymentInfo OUTPUT,  @AgPayerIdRequirementId OUTPUT,  @PayerIDRequirementMsgToShow OUTPUT,  @RequirePhotoIdImage OUTPUT,
			@PhotoIdInfo OUTPUT, @PhotoIdRecordId OUTPUT, @SenderPhotoIdOnFile OUTPUT,  @1025WithoutSign OUTPUT,  @UnVerifiedIdOnFile OUTPUT,  @UnVerifiedIdType OUTPUT,  @UnVerifiedIdNumber OUTPUT,  
			@UnVerifiedIdExpDate OUTPUT,  @UnVerifiedIdCountryAbbr OUTPUT,  @UnVerifiedIdStateId OUTPUT,  @UnVerifiedimageloc OUTPUT,  @AllowCompleteTransaction OUTPUT,  @RequestedByPayer OUTPUT,
			@RequiredNationality OUTPUT, @HitByOfacFilter OUTPUT

		IF @StsComplianceOk = 0 OR (@StsComplianceOk = 1 AND @RequirePhotoID = 1)
		BEGIN
			SET @ValidResult = 0
			SET @ErrorCode = NULL
			SET @UserErrorMessage = NULL
			SET @LogErrorMessage = NULL
		END

		IF ISNULL(@SenderIDFromHost, 0) > 0 AND ISNULL(@SndVersionId, 0) > 0 AND ISNULL(@SenderGroupId, 0) > 0
		BEGIN
			UPDATE SenderPartner with(rowlock) SET SenderId = @SenderIDFromHost, SndLastVersionId = @SndVersionId, SenderGroupId = @SenderGroupId
			WHERE SenderPartnerID = @SenderId AND Partner = @PartnerId
		END
		
		IF ISNULL(@ReceiverIDFromHost, 0) > 0 AND ISNULL(@RcvVersionId, 0) > 0 AND ISNULL(@ReceiverGroupId, 0) > 0
		BEGIN
			UPDATE ReceiverPartner with(rowlock) SET ReceiverId = @ReceiverIDFromHost, RcvLastVersionId = @RcvVersionId, ReceiverGroupId = @ReceiverGroupId
			WHERE ReceiverPartnerID = @ReceiverId AND Partner = @PartnerId
		END
		
	COMMIT
    END TRY
    BEGIN CATCH
        SET @WireResult = 1
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


