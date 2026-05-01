
CREATE procedure [dbo].[Wires_Create_Aux]
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
	@PinNumber varchar(20), 
	@Message varchar(255),
	
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
	@NewTelewire bit
)     
as  
  Set nocount on;

  RETURN
  
  DECLARE @LSenderID int, @LReceiverID int, @WireId int, @AgSenderSeq int
  DECLARE @InsSender bit, @InsReceiver bit, @DoItNow bit
  DECLARE @WireDatetime datetime, @WireDate datetime, @CheckSender bit
  declare @D datetime, @WireAvailableDate datetime
  declare @IP varchar(100), @InsertPossibleFraud bit = 0
  DECLARE @ERROR_MSG VARCHAR(MAX)

  set @D = GETDATE()
  Set @IP =  dbo.GetCurrentIP()  

INSERT INTO SP_WireLog with(rowlock)
		   (AgSenderCode, SenderName, ReceiverName, OriAmount, AgPayerCode, CreatedBy
		   ,WireDateTime, ComputerName,IPAddress, SP)
	 VALUES
		   (@AgSenderCode, @SndFullName, @RcvFullName, @OriAmount, @AgPayerCode,
		   @CreatedBy, @D, @ComputerName, @IP, 2)
				   
  if @SourceApp <> 2
     BEGIN
		INSERT INTO FAlert (AgSenderCode, SenderName, ReceiverName, OriAmount, AgPayerCode,
				            CreatedBy, WireDateTime, ComputerName, IPAddress)
			 VALUES (@AgSenderCode, @SndFullName, @RcvFullName, @OriAmount,
				     @AgPayerCode, @CreatedBy, @D, @ComputerName, @IP)
	
        RAISERROR ('Por favor cierre la aplicacion y vuelvala a abrir para Actualizar su Version de Cash Direct/ Please close this application and re-open to Update your version of Cash Direct - Preguntas / Questions: 1-800-410-6000', 16, 1)
        RETURN
     END

  if rtrim(@AgPayerCode) = 'MX-39'
    begin
     select @AgPayerId = 64964,
	        @AgPayerCode = 'MX-064',
	        @BranchId = 65254
	end
  
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


  exec SQLMAIN.[WireTransac].dbo.CFPB_CalculateWireAvailableDate_2 @WireDatetime, @AgPayerCode, 
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
            NewTelewire,WireAvailableDate)
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
            @NewTelewire,@WireAvailableDate)
            
  select @WireId = SCOPE_IDENTITY()

  -- if (suser_sname() <> 'GC_USER')
  --and (suser_sname() <> 'globalcashuser')
  --  begin
  --      INSERT INTO dbo.WirePossibleFraud with(rowlock) (WireId) values(@WireId)    
        
		--INSERT INTO FAlert (AgSenderCode, SenderName, ReceiverName, OriAmount, AgPayerCode,
		--					CreatedBy, WireDateTime, ComputerName, IPAddress)
		--	 VALUES (@AgSenderCode, @SndFullName, @RcvFullName, @OriAmount,
		--			 @AgPayerCode, @CreatedBy, @D, @ComputerName, @IP)
  --  end

   
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
          
  COMMIT;
  
  
  --exec SQLMAIN.[WireTransac].dbo.CFPB_CalculateWireAvailableDate_2 @WireDatetime, @AgPayerCode, 
  --                                                               @NoFaxBackWire, @TranTypeID, 
  --                                                               @SourceApp, @WireReplacementType,@WireAvailableDate output


 
  --update Wires with(updlock) set WireAvailableDate = @WireAvailableDate
  --where WireId = @WireId 
            
  SELECT @WireID AS WireID,
         @AgSenderSeq AS AgSenderSeq,            
         @PinNumber AS TransfPIN, 
         GetDate() AS TransfDate,
         @WireAvailableDate as WireAvailableDate,
         ' ' as ErrorMessage
   
  if @DoItNow = 1
    update BridgeProcessNow with(updlock) set DoItNow = 1  
    
  END TRY
  BEGIN CATCH
   exec spi_Error_LOG 'CREATE WIRE'
    if @@TRANCOUNT > 0
      rollback;
  END CATCH  
END TRY
BEGIN CATCH
   exec spi_Error_LOG 'CREATE WIRE'
END CATCH
