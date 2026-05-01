
CREATE procedure [dbo].[Wires_CreateAWireTransferToken_1]
(
    --Senders
	@SenderId int,
	@SenderGroupId int,
	@SndFullName varchar(150),
	@SndFirstName varchar(50),
	@SndLast1 varchar(50),
	@SndLast2 varchar(50) ,
	@SndAddress varchar(50),
	@SndCountry varchar(30),
	@SndState varchar(30),
	@SndCity varchar(40),
	@SndZip varchar(15),
	@SndPhone varchar(20),
	@SndLastVersionId int,
	@SndNoSecLastName bit,
	-- Fields add for AgPayerIdRequirements -- ( Payers that required Id over certain amount )
    @SndIdTypeName varchar(50),
    @SndIdNumber varchar(80),
    @SndIdCountryName varchar(30),
    @SndIdStateName varchar(40),
    @SndIdExpirationDate datetime,
    --Receivers
	@ReceiverId int,
	@ReceiverGroupId int,
	@RcvFullName varchar(150),
	@RcvFirstName varchar(50),
	@RcvLast1 varchar(50),
	@RcvLast2 varchar(50),
	@RcvAddress varchar(200),
	@RcvCountry varchar(30),
	@RcvState varchar(30),
	@RcvCity varchar(40),
	@RcvZip varchar(15),
	@RcvPhone varchar(20),
	@RcvNoSecLastName bit,
	@RcvLastVersionID int,
	@CPF varchar(11),
	
	--Wire info
	@AgSenderId int,
	@AgSenderCode varchar(10),
	@AgSenderState varchar(80),
	@AgSenderCity varchar(80),
	@AgSenderCountry varchar(80),
	
	@AgPayerId int,
	@AgPayerCode varchar(10),
	@DestCountry varchar(80),
	@DestState varchar(80),
	@DestCity varchar(80),
	@BranchId int,
	
	@OnBehalfId int, --Sender OnBehalf

	@OriAmount money,
	@OriCurrency char(3),
	@Charges money,
	@OtherChg money,
	@AgencyFee money,
	@OriToDestExRate money,
	@WireStateFee money,
	@WireTotalAmount money,
	@DestAmount money,
	@DestCurrency char(3),
	@AgSenderCommission money,
	@FXPointsAdded money,
	@FXChangeCost money,
	@FXCostApplyTo char(1),
	
	@TranTypeID int,
	@PayerPayMethodId int,
	@PinNumber varchar(20) output, 
	@Message varchar(255),

	@AgCompID int,
	@ComputerId varchar(126),
    @AppVersion varchar(50),
	
	--Deposit
	@AccountNumber varchar(20),
	@DeptBankName varchar(60),
	@AccountType smallint,
	@DeptAdditionalInfo varchar(60),
	@BankBranchCode varchar(7),
	
	@DeliveryType char(1),
	@SourceApp int,
	@StsCancel smallint,
	@CustTrasactionID int,
	@RateTypeID int,
	@FeePlanID int,
	@FxPlanID int,
	@AgCommiPlanID int,
	@FXDif money,
	@FXShare_id int,
	@ExRateMacro smallint,
	@WirePurpose varchar(200),
	@FundSource varchar(120),
	@Occupation varchar(80),
	@SndRcvRelationship varchar(80),
	@IncomingPhoneNumber varchar(20),
	@CallerIDVerif bit,
	@TeledirectWire bit,
	@NoFaxBackWire bit,
	@ReplacedControl int,
	@WaivedCharges money,
	@ReplaceWireRcvSel int,
	@WireReplacementType smallint,
	@ReplacementReasonID int,
    @MemberCardSwiped bit,
	@EnteredSndDOB datetime,    
	@CreatedBy varchar(15),
	@ComputerName varchar(20),
	@Compliance_GUID uniqueidentifier,
	@StsComplianceOk bit,
	@ComplianceHitsFound bit,
	@NewTelewire bit,
	@FeeChange money,
	@CostToAgent money,
	@CostToCustomer money,
	@FlexPrcOptionSelected char(1),
	@PayerSecToken int,
	@Token varchar(200),
	@WireTAG varchar(15),
    @AppHash varbinary(32),
    @PswHash  varbinary(32),
    @ClientIP varchar(50),
	-- Promotions
	@DiscountAmount MONEY, 
	@PromoCostToCompany MONEY, 
	@PromoCostToAgent MONEY, 
	@PromoCostToPayer MONEY, 
	@CRMPromotionId INT, 
	@SenderPromoUniqueKey VARCHAR(50),
    
    @WireId int output,
    @AgSenderSeq int output,
    @WireDatetime datetime2 output,
    @WireAvailableDate datetime2 output
)     
as  
  Set nocount on;
  
  DECLARE @LSenderID int, @LReceiverID int
  DECLARE @InsSender bit, @InsReceiver bit, @DoItNow bit
  DECLARE @WireDate datetime, @CheckSender bit
  DECLARE @D DATETIME 
  DECLARE @Result int, @Delay int
  DECLARE @IP varchar(100), @InsertPossibleFraud bit = 0
  DECLARE @ERROR_MSG VARCHAR(MAX)
  --if @SourceApp <> 2
  --   BEGIN
  --      RAISERROR ('Por favor llame a Soporte Tecnico/ Please call Tech Support', 16, 1)
  --      RETURN
  --   END

--insert into Test([Msg], [NUM]) values('Wires_CreateAWireTransferToken_1' + @AgSenderCode , 1)

  if @AgPayerCode is null or RTRIM(ltrim(@AgPayerCode)) = ''
    begin
      RAISERROR ('Payer information cannot be empty!', 16, 1)
      return  
    end

  if @OriToDestExRate is null or @OriToDestExRate <= 0
    begin
      RAISERROR ('Invalid Exchange rate!', 16, 1)
      return  
    end
    
  exec InsLOG @ClientIp, 0, @WireTag
  
  set @D = GETDATE()
  Set @IP =  dbo.GetCurrentIP()  

	INSERT INTO SP_WireLog with(rowlock)
			   (AgSenderCode, SenderName, ReceiverName, OriAmount, AgPayerCode
			   ,CreatedBy, WireDateTime, ComputerName, IPAddress, SP)
		 VALUES
			   (@AgSenderCode, @SndFullName, @RcvFullName, @OriAmount, @AgPayerCode,
			   @CreatedBy, @D, @ComputerName, @IP, 7)

--  insert into TEMP_Token (WireTAG, Token) 
--    values (@WireTAG, @Token)
    
  if rtrim(@AgPayerCode) = 'MX-39'
    begin
     select @AgPayerId = 64964,
	        @AgPayerCode = 'MX-064',
	        @BranchId = 65254
	end
  
  Set @Result = 0
  
  EXEC VerifyToken @ToKen, @AgSenderCode, @AgPayerCode ,@Result output, @Delay output 
  
  if @SenderID <= 0 or @SenderID is null or @ReceiverID = 0 or @ReceiverID is null
    Set @DoItNow = 1
  else  
    Set @DoItNow = 0
  
  select @InsSender = 0, @InsReceiver = 0, 
         @LSenderID = null, @LReceiverID = null,
         @WireDatetime = GETDATE(), @WireDate = dbo.DateOnly(GETDATE())
  
BEGIN TRY  

  --------Sender information-------------
  select @SenderID = IsNull(@SenderID, 0), 
         @SndLastVersionId = ISNULL(@SndLastVersionId, 0) 
  
  if @SenderID > 0
    begin
      select top 1 @LSenderID = LSenderid 
      from Senders with(nolock) where Senderid = @SenderID
      
      if @LSenderID is null
        Set @InsSender = 1
    end
  else --SenderID = 0 or null
    begin
      SELECT TOP 1 @LSenderID = LSenderId 
      FROM Senders with(nolock) 
      WHERE SndFullName = @SndFullName and 
            SndFirstName = @SndFirstName and SndLast1 = @SndLast1 and IsNull(SndLast2, '') = IsNull(@SndLast2, '') and
            SndAddress = @SndAddress and SndCity = @SndCity and SndState = @SndState and
            SndCountry = @SndCountry and SndZip = @SndZip and SndPhone = @SndPhone and
            SndNoSecLastName = @SndNoSecLastName and 
          -- SndIdTypeName = @SndIdTypeName and SndIdNumber = @SndIdNumber and SndIdCountry = @SndIdCountryName and 
          -- SndIdState = @SndIdStateName and IsNull(SndIdExpirationDate, 0) = IsNull(@SndIdExpirationDate, 0) and
             (SenderId = 0 or SenderId is null)
            
     if @LSenderID is null
       Set @InsSender = 1 
    end
  
  if @InsSender = 1
    begin
	  INSERT INTO Senders with(rowlock) 
	 		     (SenderId, SenderGroupId, SndFullName, SndFirstName, SndLast1, SndLast2, 
				  SndAddress, SndCountry, SndState, SndCity, SndZip,
				  SndPhone, SndLastVersionId, SndNoSecLastName, 
				  SndIdTypeName, SndIdNumber, SndIdCountry, SndIdState, SndIdExpirationDate)
		   VALUES
			     (@SenderId, @SenderGroupId, @SndFullName, @SndFirstName, @SndLast1, @SndLast2, 
				  @SndAddress, @SndCountry, @SndState, @SndCity, @SndZip,
				  @SndPhone, @SndLastVersionId, @SndNoSecLastName, 
				  @SndIdTypeName, @SndIdNumber, @SndIdCountryName, @SndIdStateName, @SndIdExpirationDate)
      Set @LSenderID = SCOPE_IDENTITY()
      -- Check
    end
  else 
    begin
 	 UPDATE Senders with(updlock)
	    SET SenderId = @SenderId,     SndFullName = @SndFullName, SndFirstName = @SndFirstName,
   		    SndLast1 = @SndLast1,     SndLast2 = @SndLast2,       SndAddress = @SndAddress,
   		    SndCountry = @SndCountry, SndState = @SndState,       SndCity = @SndCity,
   		    SndZip = @SndZip,         SndPhone = @SndPhone,       SndLastVersionId = @SndLastVersionId,
   		    SndNoSecLastName = @SndNoSecLastName--,
   		   -- SndIdTypeName = @SndIdTypeName, SndIdNumber = @SndIdNumber, SndIdCountry = @SndIdCountryName, 
   		   -- SndIdState = @SndIdStateName, SndIdExpirationDate = @SndIdExpirationDate
     WHERE LSenderId = @LSenderID
     -- Update Information if You Have IdInformation for AgPayerIdRequirement
     IF ( LEN(RTRIM(@SndIdTypeName)) > 0 AND LEN(RTRIM(@SndIdNumber)) > 0 )
		BEGIN
			IF ( LEN(RTRIM(@SndIdCountryName)) = 0 AND LEN(RTRIM(@SndIdStateName)) = 0  AND @SndIdExpirationDate is null)
				BEGIN
				-- Just Update Id Type Name and Id Number
					UPDATE Senders WITH (UPDLOCK)
						SET SndIdTypeName = @SndIdTypeName , SndIdNumber = @SndIdNumber
					WHERE LSenderId = @LSenderID;				
				END	
			ELSE
				BEGIN
				-- Update All Fields
					UPDATE Senders WITH (UPDLOCK)
						SET SndIdTypeName = @SndIdTypeName 
						, SndIdNumber = @SndIdNumber
						, SndIdCountry = @SndIdCountryName
						, SndIdState = @SndIdStateName
						, SndIdExpirationDate = @SndIdExpirationDate
					WHERE LSenderId = @LSenderID;								
				END		
		END
    END

  ---------Receiver info-----------
  select @ReceiverId = IsNull(@ReceiverId, 0), 
         @RcvLastVersionID = ISNULL(@RcvLastVersionID, 0) 
  
  if @ReceiverId > 0
    begin
      select top 1 @LReceiverID = LReceiverId 
      from Receivers with(nolock) where ReceiverId = @ReceiverId
      
      if @LReceiverID is null
        Set @InsReceiver = 1
    end
  else
    begin
      SELECT top 1 @LReceiverID = LReceiverId 
      FROM Receivers with(nolock)
      WHERE RcvFullName = @RcvFullName and
            RcvFirstName = @RcvFirstName and RcvLast1 = @RcvLast1 and IsNull(RcvLast2, '') = IsNull(@RcvLast2, '') AND
            RcvAddress = @RcvAddress and  RcvCity = @RcvCity and
            RcvState = @RcvState and RcvCountry = @RcvCountry and
            IsNull(RcvZip, '') = IsNull(@RcvZip, '') and IsNull(RcvPhone, '') = IsNull(@RcvPhone, '') and IsNull(CPF, '') = IsNull(@CPF, '') and
            (ReceiverId = 0 or ReceiverId is null) 
            
      if @LReceiverID is null
        Set @InsReceiver = 1
    end 
   
  if @InsReceiver = 1
    begin
  	  INSERT INTO Receivers with(rowlock)
	  		     (ReceiverId, ReceiverGroupId, RcvFullName, RcvFirstName,
			      RcvLast1, RcvLast2, RcvAddress, RcvCountry,
			      RcvState, RcvCity, RcvZip, RcvPhone,
			      RcvNoSecLastName, RcvLastVersionID, CPF)
		 VALUES
	  		     (@ReceiverId, @ReceiverGroupId, @RcvFullName, @RcvFirstName,
			      @RcvLast1, @RcvLast2, @RcvAddress, @RcvCountry,
			      @RcvState, @RcvCity, @RcvZip, @RcvPhone,
			      @RcvNoSecLastName, @RcvLastVersionID, @CPF)
			      
	  select @LReceiverID = SCOPE_IDENTITY()	      
    end  
  else
    begin
      UPDATE Receivers with(updlock)
         SET ReceiverId = @ReceiverId,     ReceiverGroupId = @ReceiverGroupId,
             RcvFullName = @RcvFullName,   RcvFirstName = @RcvFirstName,
             RcvLast1 = @RcvLast1,         RcvLast2 = @RcvLast2,
             RcvAddress = @RcvAddress,     RcvCountry = @RcvCountry,
             RcvState = @RcvState,         RcvCity = @RcvCity,
             RcvZip = @RcvZip,             RcvPhone = @RcvPhone,
             RcvNoSecLastName = @RcvNoSecLastName, 
             RcvLastVersionID = @RcvLastVersionID,
             CPF = @CPF
       WHERE LReceiverId = @LReceiverID    
    end 

  if @ExRateMacro is null 
    set @ExRateMacro = 1  --1- Regula 2- Macro 3- Super macro

  --exec SQLMAIN.[WireTransac].dbo.CFPB_CalculateWireAvailableDate_2 @WireDatetime, @AgPayerCode, 
  --                                                               @NoFaxBackWire, @TranTypeID, 
  --                                                               @SourceApp, @WireReplacementType,@WireAvailableDate output

   exec SQLMAIN.[WireTransac].dbo.CFPB_CalculateWireAvailableDate_3 @WireDatetime, @AgPayerCode, @BranchId,
                                                                 @NoFaxBackWire, @TranTypeID, 
                                                                 @SourceApp, @WireReplacementType,@WireAvailableDate output

 BEGIN TRY   
  BEGIN TRAN   
  ---Get PIN Number
  if rtrim(@PinNumber) = '' or @PinNumber is null
    exec WireKeys.dbo.sps_GetPINNumber @AgPayerCode, @PinNumber output  

  ---Agency Sequence Number  
  exec WireKeys.dbo.sps_GenAgencySeq @AgSenderCode, @AgSenderSeq output  

  SET @OriAmount          = ROUND(@OriAmount,2)
  SET @DestAmount         = ROUND(@DestAmount,2)
  SET @WireTotalAmount    = ROUND(@WireTotalAmount,2)
  SET @AgSenderCommission = ROUND(@AgSenderCommission,2)
  
  --------Insert Transfer-------
  INSERT INTO Wires with(rowlock)
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
            WirePurpose, FundSource, Occupation ,
            IncomingPhoneNumber ,CallerIDVerif ,TeledirectWire ,NoFaxBackWire,
            ReplacedControl ,WaivedCharges, ReplaceWireRcvSel, WireReplacementType ,ReplacementReasonID, 
            MemberCardSwiped ,CreatedBy ,ComputerName, CustMessage, ExRateMacro, SndDOB,SndRcvRelationship,
            NewTelewire, AgComputerid, ComputerId, AppVersion, TkDelay, FeeChange, CostToAgent ,CostToCustomer,
            FlexPrcOptionSelected, PayerSecToken, WireAvailableDate, ClientIP,
            DiscountAmount, PromoCostToCompany, PromoCostToAgent, PromoCostToPayer, CRMPromotionId, SenderPromoUniqueKey)
     VALUES
           (@LSenderID, @LReceiverID, @AgSenderId, @AgSenderCode,
            @AgSenderSeq, @AgSenderState, @AgSenderCity, @AgSenderCountry,
            @AgPayerId, @AgPayerCode, @DestCountry, @DestState,
            @DestCity, @BranchId, @SenderId, @OnBehalfId,
            @ReceiverId, @SndFullName, null, @RcvFullName,
            @PinNumber, @WireDate, @WireDatetime, @OriAmount,
            @OriCurrency, @Charges, @OtherChg, @AgencyFee,
            @OriToDestExRate, @WireStateFee,
            @WireTotalAmount, @DestAmount, @DestCurrency, @AgSenderCommission,
            @FXPointsAdded,@FXChangeCost,@FXCostApplyTo,
            @TranTypeID, @AccountNumber, @DeptBankName, @AccountType,
            @DeptAdditionalInfo, @BankBranchCode, @DeliveryType, @SourceApp,
            @StsComplianceOk, @StsCancel, @CustTrasactionID, @RateTypeID,@PayerPayMethodId,
            @FeePlanID, @FxPlanID, @AgCommiPlanID, @FXDif, @FXShare_id, 
            @WirePurpose, @FundSource, @Occupation ,            
            @IncomingPhoneNumber, @CallerIDVerif, @TeledirectWire, @NoFaxBackWire,
            @ReplacedControl, @WaivedCharges, @ReplaceWireRcvSel, @WireReplacementType, @ReplacementReasonID,
            @MemberCardSwiped, @CreatedBy, @ComputerName, @Message, @ExRateMacro, @EnteredSndDOB,@SndRcvRelationship,
            @NewTelewire, @AgCompID, @ComputerId, @AppVersion, @Delay, @FeeChange, @CostToAgent , @CostToCustomer,
            @FlexPrcOptionSelected, @PayerSecToken, @WireAvailableDate, @ClientIP,
            @DiscountAmount, @PromoCostToCompany, @PromoCostToAgent, @PromoCostToPayer, @CRMPromotionId, @SenderPromoUniqueKey)
            
  select @WireId = SCOPE_IDENTITY()

  insert into WiresTAG with(rowlock) (WireTAG, WireID, PswHash, AppHash, AgComputerid) 
                              values(@WireTAG, @WireId, @PswHash, @AppHash, @AgCompID)

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
  exec PossibleFraudeCheck 2, @WireId, @AgCompID, @ComputerName, @Result, @AgSenderCode, @CreatedBy, @Token, @PswHash, @InsertPossibleFraud output 
  
  if @InsertPossibleFraud = 1
    update Wires with(updlock) set PossibleFraud = 1
    where WireId = @WireId
    
/*  declare @DMinus16 datetime
  Set @DMinus16 = DATEADD(hour, -18, GETDATE())
  
  if Exists(select * from Wires T1
            where WireId = @WireId and
				   not Exists(select *
							  from WireSearch.dbo.LOG_AgenciesAppLogins T01
                                join WireSearch.dbo.AgencyComputers T02 ON T01.AgComputerId = T02.AgComputerId
							 where T01.AgencyCode = T1.AgSenderCode and 
								   T01.UserName = T1.CreatedBy and
								   T02.ComputerName = @ComputerName and
								   T01.Created >= @DMinus16)
							 )
     begin
       Set @InsertPossibleFraud = 1 
     end
     
   if suser_sname() not in ('CashDirectUsr', 'CashDirectUsrSecond2') or 
      (@AgCompID = 0 or @AgCompID is null) or
      @Result <> 0 or 
      dbo.fn_IsPayerTokenOk(@WireId) = 0 or
      dbo.fn_IsAgUserPswOk(@AgSenderCode, @CreatedBy, @PswHash) = 0
     Set @InsertPossibleFraud = 1 
     
    if @InsertPossibleFraud = 1
      begin
        INSERT INTO dbo.WirePossibleFraud with(rowlock) (WireId, TokenResult, S, Token) values(@WireId, @Result, 2, @Token)
        
		INSERT INTO FAlert (AgSenderCode, SenderName, ReceiverName, OriAmount, AgPayerCode,
				            CreatedBy, WireDateTime, ComputerName, IPAddress)
			 VALUES (@AgSenderCode, @SndFullName, @RcvFullName, @OriAmount,
				     @AgPayerCode, @CreatedBy, @D, @ComputerName, @IP)
      end
*/  
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
  
  insert into TEST(Msg) values('Wires_CreateAWireTransferToken_1')
  
  INSERT INTO ProcessedWires with(rowlock) (WireID, Done) Values(@WireID, 0)
    
  if @ComplianceHitsFound = 1 or @StsComplianceOk = 0
    begin
      UPDATE WireCompliance.dbo.Comp_WireOnHold with(updlock) Set WireId = @WireId
      WHERE GuidId = @Compliance_GUID
      
      UPDATE WireCompliance.dbo.LogAmountWarnMsg WITH(updlock) SET Wire_ID = @WireId
      WHERE CompGuidId = @Compliance_GUID
    end

  exec WireCompliance.dbo.spi_Create_CumulativeSummaryAmountsToday_
            @WireId,
			@OriAmount, 
			@SndFullName, @OriCurrency, 
			@SndCountry, @AgSenderState, @AgSenderCity,
			@RcvFullName, @DestCurrency,
			@DestCountry, @DestState, @DestCity,
			@SndPhone, @RcvPhone,
			@DeptBankName, @AccountNumber, @AgPayerCode

  UPDATE WiresCFPBLog WITH(UPDLOCK) SET AgSenderSeq = @AgSenderSeq
  WHERE WireTAG = @WireTAG         
  
  COMMIT;
  
  --exec SQLMAIN.[WireTransac].dbo.CFPB_CalculateWireAvailableDate_2 @WireDatetime, @AgPayerCode, 
  --                                                               @NoFaxBackWire, @TranTypeID, 
  --                                                               @SourceApp, @WireReplacementType,@WireAvailableDate output
 
  --update Wires with(updlock) set WireAvailableDate = @WireAvailableDate
  --where WireId = @WireId 
/*  
  SELECT @WireID AS WireID,
         @AgSenderSeq AS AgSenderSeq,            
         @PinNumber AS TransfPIN, 
         GetDate() AS TransfDate, 
         @WireAvailableDate as WireAvailableDate,
         ' ' as ErrorMessage
  
*/
   
  if @DoItNow = 1
    update BridgeProcessNow with(updlock) set DoItNow = 1  
    
  END TRY
  BEGIN CATCH
 --  exec spi_Error_LOG 'CREATE WIRE'
   DECLARE @ErrorMessage VARCHAR(4000);
   SELECT @ErrorMessage = ERROR_MESSAGE()
    if @@TRANCOUNT > 0
      rollback;
  
   
   INSERT INTO dbo.ErrorLog (ProcessName, ErrorMsg) values('CreateAWireTransferToken_1', @ERROR_MSG)
  END CATCH  
END TRY
BEGIN CATCH
   exec spi_Error_LOG 'CREATE WIRE'
END CATCH
