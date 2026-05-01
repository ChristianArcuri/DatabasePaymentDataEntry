
CREATE procedure [dbo].[spi_CreateWireTransfer_DataEntry_OldMar07]
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
	@TranTypeID int,
	@PinNumber varchar(20), 
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
	@Elect1025_IDOk bit,
	@CreatedBy varchar(15),
	@ComputerName varchar(20),
	@WirePoints int, 
	@WirePointsSign int
)     
as  
  Set nocount on;
  
  DECLARE @LSenderID int, @LReceiverID int, @WireId int, @AgSenderSeq int
  DECLARE @InsSender bit, @InsReceiver bit, @DoItNow bit
  DECLARE @Compliance_GUID uniqueidentifier, @RequireWireAddInf bit, @ComplianceHitsFound bit
  DECLARE @WireDatetime datetime, @WireDate datetime, @StsComplianceOk bit, @CheckSender bit
  declare @M varchar(1024), @WireAvailableDate datetime
  
  DECLARE @ERROR_MSG VARCHAR(MAX)

  if rtrim(@AgPayerCode) = 'MX-064' 
    begin
      Set @M = 'El pagador no esta active. Por favor llame al Servicio al Cliente.' + char(13) + 'The Payer is not active. Call Customer Service.'
      RAISERROR (@M, 16, 1)
/*     select @AgPayerId = 64964,
	        @AgPayerCode = 'MX-064',
	        @BranchId = 65254*/
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
            SndLastVersionId = @SndLastVersionId and SndNoSecLastName = @SndNoSecLastName and 
            (SenderId = 0 or SenderId is null)
            
     if @LSenderID is null
       Set @InsSender = 1 
    end
  
  if @InsSender = 1
    begin
	  INSERT INTO Senders with(rowlock) 
	 		     (SenderId, SenderGroupId, SndFullName, SndFirstName, SndLast1, SndLast2, 
				  SndAddress, SndCountry, SndState, SndCity, SndZip,
				  SndPhone, SndLastVersionId, SndNoSecLastName)
		   VALUES
			     (@SenderId, @SenderGroupId, @SndFullName, @SndFirstName, @SndLast1, @SndLast2, 
				  @SndAddress, @SndCountry, @SndState, @SndCity, @SndZip,
				  @SndPhone, @SndLastVersionId, @SndNoSecLastName)
      Set @LSenderID = SCOPE_IDENTITY()
    end
  else 
    begin
 	 UPDATE Senders with(updlock)
	    SET SenderId = @SenderId,     SndFullName = @SndFullName, SndFirstName = @SndFirstName,
   		    SndLast1 = @SndLast1,     SndLast2 = @SndLast2,       SndAddress = @SndAddress,
   		    SndCountry = @SndCountry, SndState = @SndState,       SndCity = @SndCity,
   		    SndZip = @SndZip,         SndPhone = @SndPhone,       SndLastVersionId = @SndLastVersionId,
   		    SndNoSecLastName = @SndNoSecLastName
     WHERE LSenderId = @LSenderID
    end

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

  -----Compliance-----------
  if @WireReplacementType = 2 --if it is a New wire replacing other (Replacement wire) No sender Checking
    Set @CheckSender = 0
  else
    Set @CheckSender = 1
  
  if @TranTypeID <> 6
	  exec WireCompliance.dbo.Comp_WiresFilters
			  @SenderId, 
			  @SenderGroupId,
			  @ReceiverId, 
			  0/*@onBehalfId*/, 
			  @SndFullName, 
			  @RcvFullName, 
			  null /*@onBehalfFullName*/, 
			  @DeptBankName, --@deptBankName
			  @AccountNumber, --@accountNumber, 
			  @AgSenderCode, 
			  @AgPayerCode, 
			  @AgSenderCountry /*@oriCountry*/, 
			  @AgSenderState /*@oriState*/, 
			  @AgSenderCity /*@oriCity*/,
			  @DestCountry, 
			  @DestState, 
			  @DestCity, 
			  @OriAmount, 
			  @OriCurrency, 
			  @WireTotalAmount,
			  @TranTypeID,
			  @SndPhone, 
			  @RcvPhone, 
			  @SndZip, 
			  @SndFirstName, 
			  @SndLast1, 
			  @SndLast2,
			  @RcvFirstName, 
			  @RcvLast1, 
			  @RcvLast2,
			  null /* @onbFirstName*/, null /*@onbLast1*/, null /*@onbLast2 VARCHAR(50)*/, 
			  @Elect1025_IDOk,
			  @CheckSender,
			  @RequireWireAddInf OUTPUT, @ComplianceHitsFound OUTPUT, @Compliance_GUID OUTPUT	,@StsComplianceOk OUTPUT
  else

    select @RequireWireAddInf = 0, @ComplianceHitsFound = 0, @Compliance_GUID = null, @StsComplianceOk = 1
    
 
  
  if @ExRateMacro is null 
    set @ExRateMacro = 1  --1- Regula 2- Macro 3- Super macro

 exec SQLMAIN.[WireTransac].dbo.CFPB_CalculateWireAvailableDate_3 @WireDatetime, @AgPayerCode, @BranchId,
                                                                  0, @TranTypeID, 
                                                                  @SourceApp, @WireReplacementType,@WireAvailableDate output


 BEGIN TRY   
  BEGIN TRAN   
  ---Get PIN Number
  if rtrim(@PinNumber) = '' or @PinNumber is null
    exec WireKeys.dbo.sps_GetPINNumber @AgPayerCode, @PinNumber output  

  ---Agency Sequence Number  
  exec WireKeys.dbo.sps_GenAgencySeq @AgSenderCode, @AgSenderSeq output  

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
            TranTypeID ,AccountNumber ,DeptBankName ,AccountType,
            DeptAdditionalInfo ,BankBranchCode ,DeliveryType ,SourceApp,
            StsComplianceOk ,StsCancel ,CustTrasactionID, RateTypeID,
            FeePlanID, FxPlanID, AgCommiPlanID, FXDif, FXShare_id,
            WirePurpose, FundSource, Occupation ,
            IncomingPhoneNumber ,CallerIDVerif ,TeledirectWire ,NoFaxBackWire,
            ReplacedControl ,WaivedCharges, ReplaceWireRcvSel, WireReplacementType ,ReplacementReasonID, 
            MemberCardSwiped ,CreatedBy ,ComputerName, CustMessage, ExRateMacro, SndDOB,
            FXPointsAdded,FXChangeCost, PayerPayMethodId,
            AgComputerid, ComputerId, AppVersion, WirePoints, WirePointsSign, WireAvailableDate)
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
            @TranTypeID, @AccountNumber, @DeptBankName, @AccountType,
            @DeptAdditionalInfo, @BankBranchCode, @DeliveryType, @SourceApp,
            @StsComplianceOk, @StsCancel, @CustTrasactionID, @RateTypeID,
            @FeePlanID, @FxPlanID, @AgCommiPlanID, @FXDif, @FXShare_id, 
            @WirePurpose, @FundSource, @Occupation ,            
            @IncomingPhoneNumber, @CallerIDVerif, @TeledirectWire, @NoFaxBackWire,
            @ReplacedControl, @WaivedCharges, @ReplaceWireRcvSel, @WireReplacementType, @ReplacementReasonID,
            @MemberCardSwiped, @CreatedBy, @ComputerName, @Message, @ExRateMacro, @EnteredSndDOB,
            0, 0, (case when @AgPayerCode = 'GU-02' and @DestCurrency = 'USD' then 3 else 1 end),
            @AgCompID, @ComputerId, @AppVersion, @WirePoints, @WirePointsSign, @WireAvailableDate)
            
  select @WireId = SCOPE_IDENTITY()

  if @SourceApp = 6
    begin
	  declare @DMinus16 datetime
	  Set @DMinus16 = DATEADD(hour, -18, GETDATE())
    
      --if Exists(select * from Wires T1
      --          where WireDate = dbo.DateOnly(GETDATE()) and 
      --                WireId = @WireId and
					 --  not Exists(select *
						--		 from WireSearch.dbo.LOG_AgenciesAppLogins T01
						--		 where T01.AgencyCode = T1.AgSenderCode and 
						--			   T01.UserName = T1.CreatedBy and
						--			   dbo.DateOnly(T01.Created) = dbo.DateOnly(GETDATE())
						--		 ))		
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
           INSERT INTO dbo.WirePossibleFraud (WireId, S) values(@WireId, 2)
         end
    end

  SELECT @WireId as WireId,
         @AgSenderSeq AS AgSenderSeq,            
         @PinNumber AS TransfPIN, 
         @StsComplianceOk AS TransfStsComplianceOk,
         @RequireWireAddInf as RequireAdditionalInfo,
         @WireDate AS TransfDate,
         @Compliance_GUID as CompGUID,
         ' ' as ErrorMessage

  INSERT INTO ProcessedWires with(rowlock) (WireID, Done) Values(@WireID, 0)
    
  if @ComplianceHitsFound = 1
    UPDATE WireCompliance.dbo.Comp_WireOnHold with(updlock) Set WireId = @WireId
    WHERE GuidId = @Compliance_GUID


	 -- IRS REQUEST
     IF EXISTS (Select * FROM WireCompliance.dbo.Comp_WiresOnIRSHold Where GuidId  = @Compliance_GUID)
	    begin
		  UPDATE WireCompliance.dbo.Comp_WiresOnIRSHold with(updlock) Set WireId = @WireId
           WHERE GuidId = @Compliance_GUID
		end
  -- END IRS REQUEST

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