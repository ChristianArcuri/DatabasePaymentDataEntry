CREATE PROCEDURE [dbo].[WebAgent_WireCreate_Fase3_WhiteLabel_RcvIdType_Gateway]  
    @PreparationId uniqueIdentifier,  
    @WebAgentTransationId uniqueIdentifier,  
 --Senders  
 @WebAgentUserId int,  
 @CurrentWebLanguageId int,  
  
 --Receivers  
 @ReceiverId int,  
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
 @RcvDOB datetime,  
  
 --Wire info  
  
 @WireStateFrom varchar(30),  
 @AgPayerId int,  
 @AgPayerCode varchar(10),  
 @DestCountry varchar(30),  
 @DestState varchar(30),  
 @DestCity varchar(40),  
 @BranchId int,  
 @TranTypeID int,  
 @DeliveryMethod char(1),  
   
 --Deposit  
 @AccountNumber varchar(30),  
 @DeptBankName varchar(60),  
 @AccountType smallint,  
 @DeptAdditionalInfo varchar(60),  
 @BankBranchCode varchar(7),  
 @AgPayerRcvIdTypeRecordId int,
 @RcvIdNumber varchar(80),
  
 --Amounts  
 @OriAmount money,  
 @OriCurrency char(3),  
 @WireFee money,  
 @SndPaymentMethodExtraFee money,   
 @FX money,  
 @WireStateFee money,  
 @WireTotalAmount money,  
 @DestAmount money,  
 @DestCurrency char(3),  
  
 --Compliance   
 @WirePurpose varchar(200),  
 @FundSource varchar(120),  
 @Occupation varchar(80),  
 @SndRcvRelationship varchar(80),  
 @StsComplianceOk bit,  
  
 -- Promotions and Points  
 @DiscountAmount MONEY,   
 @PromotionCode varchar(20),     
   
 @PointsToRedeem int, --New x Loyalty  
 @PointsRedemptionId int, --New x Loyalty  
 @OptStatus char(1),  
   
  
 --AuditInfo  
   
 @ComputerName varchar(20),  
 @WireIPAddress varchar(50),  
 @IPDetectedState varchar(40),  ----Lo Busco en InPreparation
  
 --SenderPaymentInfo  
 @SenderPaymentMethodId int,  
    @UserPaymentMethodInfoId int,  
	@GatewayId int,
    @GatewayToken varchar(30),  
  
  
 --Parametros de Salida  
 @WireResult int OUTPUT,  
 @ErrorCode varchar(10) OUTPUT,  
    @UserErrorMessage varchar(300) OUTPUT,  
    @LogErrorMessage varchar(MAX) OUTPUT,  
  
 @PinNumber varchar(20) OUTPUT  
    --@WireAvailableDate date OUTPUT,  
 --@WireReadyToChargeSender bit OUTPUT, No Mas  
 --@MsgToShow varchar(max) OUTPUT  
  
  
      
      
as    
  Set nocount on;  
  
  
  DECLARE @ReceiverGroupId int = 0  
  DECLARE @OnBehalfId int = 0 --Sender OnBehalf   
  DECLARE @AgencyFee money = 0  
  DECLARE @OtherChg money   
  DECLARE @OriToDestExRate money   
  DECLARE @PayerPayMethodId int   
  DECLARE @CreatedBy varchar(15)   
    
  DECLARE @Charges money   
  DECLARE @Message varchar(255) = ''  
  DECLARE @SourceApp int  
  DECLARE @StsCancel smallint =0  
  DECLARE @CustTrasactionID int = 0  
  DECLARE @ExRateMacro smallint = 1  
  DECLARE @RateTypeID int  
  DECLARE @IncomingPhoneNumber varchar(20) =''  
  DECLARE @CallerIDVerif bit = 0  
  DECLARE @TeledirectWire bit = 0  
  DECLARE @NoFaxBackWire bit = 0  
  DECLARE @NewTelewire bit = 0  
  DECLARE @SndFullName varchar(150) = ''  
  DECLARE @AgSenderState varchar(30)  
  DECLARE @AgSenderCity varchar(40)  
  DECLARE @AgSenderCountry varchar(30)  
  DECLARE @RealTimeAchOK BIT = 0  
  DECLARE @SndCountry varchar(40)  
  DECLARE @SndPhone varchar(20)  
  DECLARE @RcvFullName varchar(150)   
  --WireReplacements (Change of Beneficiary)  
  DECLARE @ReplacedControl int          = 0  
  DECLARE @WaivedCharges money          = 0  
  DECLARE @ReplaceWireRcvSel int        = ''  
  DECLARE @WireReplacementType smallint = 0  
  DECLARE @ReplacementReasonID int      = 0  
  DECLARE @MemberCardSwiped bit = 0  
  DECLARE @WireReadyToChargeSender bit  
  DECLARE @WireAvailableDate datetime  
  DECLARE @DateOnly datetime
  DECLARE @DeviceFingerprint  varchar(50)
  DECLARE @ChannelId int = 0
  DECLARE @PartnerId int = 0


  set @DateOnly = DBO.DateOnly(getdate())
  
  
  --============================OBTENER DATOS GUARDADOS EN PREPARACION======================  
  
DECLARE   
@SenderId int,  
@SameSenderId int , -- New x Loyalty  
@AcumLoyaltyPoints bit, --New x Loyalty  
  
@AgSenderId int,  
@AgSenderCode varchar(10),  
  
@AgSenderCommission money,  
@FXPointsAdded money,  
@FXChangeCost money,  
@FXCostApplyTo char(1),  
  
  
  
@FeePlanID int,  
@FxPlanID int,  
@AgCommiPlanID int,  
@FXDif money,  
@FXShare_id int,  
  
@CRMPromotionId INT,   
@PromoCostToCompany MONEY,   
@PromoCostToAgent MONEY,   
@PromoCostToPayer MONEY,   
@WiresAlreadyCountGUID uniqueidentifier,  
@SenderPromoUniqueKey  VARCHAR(20),  
  
@WirePoints INT,   
@WirePointsSign INT,  
  
@ComplianceHitsFound bit,  
  
@Electronic1025 bit,  
@SenderGRoupId int  ,
@CreditLimitcheckResult int,
@StsCreditOk bit,
@AgPayerIdRequirementId int,
@Today datetime,
@OnHoldRecordId int

set @Today = dbo.DateOnly(getdate())
 
--Clean Receiver Name Info
SET @RcvFirstName = dbo.CleanRecieverNameInfo(@RcvFirstName);
SET @RcvLast1 = dbo.CleanRecieverNameInfo(@RcvLast1);
SET @RcvLast2 = dbo.CleanRecieverNameInfo(@RcvLast2); 
       
 -- INSERT INTO DebugGeru VALUES  (@WebAgentTransationId)  
  
--  insert into WebAgent_TimeLog (WebAgentTransationId,d,pinnumber) values (@WebAgentTransationId,getdate(),'')

  SELECT @WireResult = 0,  
      @ErrorCode = '',  
         @UserErrorMessage = '',  
         @LogErrorMessage = '',  
      @PinNumber = PinNumber  
    FROM Wires  
   WHERE WebAgentTransationId = @WebAgentTransationId  
  IF @@ROWCOUNT <> 0  
     BEGIN  
       SET @WireResult  = 1  
       SET @ErrorCode = '10860' --TransactionId already exists  
       SET @UserErrorMessage =  ''  
       SET @LogErrorMessage = dbo.fnc_EcoMessage_withLanguage ('10860',@CurrentWebLanguageId)   
    RETURN      
  END  
     
   
  
  
  SET @OtherChg          = @SndPaymentMethodExtraFee  
  SET @OriToDestExRate   = @FX  
  SET @PayerPayMethodId  = 1   
  SET @Charges           = @WireFee  
  SET @RcvFullName       = rtrim(rtrim(@RcvFirstName)+' '+rtrim(@RcvLast1)+' '+rtrim(@RcvLast2))  
  SET @RateTypeId        = 1  
  
SELECT @ChannelId             = ChannelId   
      ,@PartnerId             = PartnerId
      ,@SenderId              = SenderId  
      ,@SameSenderId          = SameSenderId  
      ,@AcumLoyaltyPoints     = AcumLoyaltyPoints  
  
      ,@AgSenderCode          = AgSenderCode  
      ,@AgSenderId            = AgSenderId  
  
      ,@AgSenderCommission    = SndCommissionAmount    
  
      ,@FXPointsAdded         = FXPointsAdded  
      ,@FXChangeCost          = FXChangeCost  
      ,@FXCostApplyTo         = FXCostApplyTo  
  
      ,@FeePlanID             = FeePlanID  
      ,@AgCommiPlanID         = CommPlanID  
      ,@FxPlanID              = RatePlanID  
      ,@FXDif                 = FXDif  
      ,@FXShare_id            = FXShareId  
  
      ,@CRMPromotionId        = CRMPromotionId  
      ,@PromoCostToCompany    = PromoCostToCompany  
      ,@PromoCostToAgent      = PromoCostToAgent  
      ,@PromoCostToPayer      = PromoCostToPayer  
      ,@WiresAlreadyCountGUID = WiresAlreadyCountGUID  
      ,@SenderPromoUniqueKey  = SenderPromoUniqueKey  
      ,@WirePoints            = WirePoints  
      ,@WirePointsSign        = WirePointsSign  
      ,@ComplianceHitsFound   = ComplianceHitsFound  
      ,@WireReplacementType   = ISNULL(WireReplacementType,0)  
      ,@ReplacedControl       = ISNULL(ReplacedControl ,0)  
      ,@Electronic1025        = Electronic1025  
	  ,@CreditLimitcheckResult = CreditLimitCheckResult
	  ,@DeviceFingerprint      = DeviceFingerprint
	  ,@IPDetectedState        = IPDetectedState
	  ,@AgPayerIdRequirementId = AgPayerIdRequirementId 
  FROM PaymentDataEntry.dbo.WebAgent_WireInPreparation  
 WHERE PreparationId = @PreparationId  
  
 IF @@ROWCOUNT = 0  
    BEGIN  
   SET @WireResult  = 500  
      SET @ErrorCode = ''  
      SET @UserErrorMessage =  ''  
      SET @LogErrorMessage = 'No se pudo recuperar los datos de preparacion  '   
   RETURN  
 END  
  
 SELECT @SenderGroupId = SenderGroupId  
   FROM WireSearch.dbo.Senders  
  WHERE SenderId = @SenderId  
 IF @@ROWCOUNT <> 1  
    BEGIN  
      SET @SenderGRoupId = 0  
   SET @Electronic1025 = 0  
    END  
  
 IF EXISTS (SELECT *  
                  FROM WireCompliance.dbo.Comp_WireOnHold H  
                 WHERE GuidId = @WebAgentTransationId AND Status = 'P')  
         BEGIN  
           SET @StsComplianceOk = 0  
         END  
     ELSE BEGIN  
            SET @StsComplianceOk = 1   
          END  
     --Veriricar si se puese liberar por electronic 1025 y el remitente ya tiene id on file   
 IF @StsComplianceOk = 0  
   AND @Electronic1025  = 1  
       BEGIN  
      IF EXISTS (SELECT i.RecordId  FROM WireSearch.dbo.Comp_SenderIDs as i  
                               inner join Wirecompliance.dbo.Comp_IdTypes as t on i.IdTypeName = t.IdTypeName  
                     Where SenderGroupId = @SenderGroupId  and PhotoID = 1 )  
   BEGIN  
     UPDATE WireCompliance.dbo.Comp_WireOnHold SET AuthoDate =  getdate(),  
                                                   Comment   = 'Electronic 1025',  
                                                            Status    = 'A',  
                              AuthoUserName = 'SYSTEM'  
    WHERE GuidId = @WebAgentTransationId  
      AND OnHoldReasonId in (Select OnHoldReasonId FROM WireCompliance.dbo.Comp_OnHoldReasons as r  
                              Where r.Electronic1025 = 1  
              and r.Electronic1025MaxAmount >= @oriAmount  
           and r.Status = 'A')  
   END  
    END  
  
  
   IF EXISTS (SELECT *  
                  FROM WireCompliance.dbo.Comp_WireOnHold H  
                 WHERE GuidId = @WebAgentTransationId AND Status = 'P')  
         BEGIN  
           SET @StsComplianceOk = 0  
         END  
     ELSE BEGIN  
            SET @StsComplianceOk = 1   
          END  
  
  ---Si el giro no quedo retenido por compliance pero el pagador requiere ID y no lo ingreso lo retengo x compliance
  --On Hold Reason WAITING FOR ID AS PAYER REQUEST
   --IF @StsComplianceOk = 1
   --   BEGIN
	    IF @AgPayerIdRequirementId > 0
		   BEGIN
		     IF NOT EXISTS (SELECT i.RecordId  FROM SqlMain.WireTransac.dbo.Comp_SenderIDs as i  
                               inner join Wirecompliance.dbo.Comp_IdTypes as t on i.IdTypeName = t.IdTypeName  
                     Where SenderGroupId = @SenderGroupId  and PhotoID = 1 and i.idexpirationdate > @Today )  
				BEGIN
				  SET @StsComplianceOk = 0
				  exec WireCompliance.dbo.Comp_WireOnHold_Create @WebAgentTransationId, 112,null ,'WEBAGENT','Need to provide photo id','P', 0, 'USD', @OnHoldRecordId output
				END
		   END
	--  END
               
  
 SELECT  @SourceApp = AppId,  
         @CreatedBy  = UserName  
   FROM WireSearch.dbo.Switch_Channels  
  WHERE ChannelId = @ChannelId  
 IF @@ROWCOUNT  = 0  
    SET @SourceApp = 37 --WebAgent  
  
  IF (@DestState IS NULL OR rtrim(@DestState) = '')  
     BEGIN  
    SELECT @DestState = BrState,  
           @DestCity  = BrCity  
   FROM WireSearch.dbo.Branches  
  WHERE BranchId = @BranchId  
  END  
  
  
  
  DECLARE @ReCalcTotalAmount money  
  DECLARE @RcCalcDestAmount money  
  
   Set @ReCalcTotalAmount = IsNull(@OriAmount, 0) + IsNull(@Charges, 0) + IsNull(@OtherChg, 0) +   
                            IsNull(@AgencyFee, 0) + IsNull(@WireStateFee, 0) - IsNull(@DiscountAmount, 0)  
            
   if Abs(ROUND(@ReCalcTotalAmount, 2) - @WireTotalAmount) > 0.01  
    begin  
      SET @WireResult  = 500  
      SET @ErrorCode = ''  
      SET @UserErrorMessage =  ''  
      SET @LogErrorMessage = 'Invalid Total Amount'   
   RETURN  
    end  
  
   SET @RcCalcDestAmount = @OriAmount * @OriToDestExRate  
   IF Abs(ROUND(@RcCalcDestAmount, 2) - @DestAmount) > 0.01  
   begin  
      SET @WireResult  = 500  
      SET @ErrorCode = ''  
      SET @UserErrorMessage =  ''  
      SET @LogErrorMessage = 'Invalid Dest Amount'   
   RETURN  
    end  
  
  --=============================================================  
  IF @TranTypeID = 1  
     BEGIN  
    SET @AccountNumber = ''  
    SET @BankBranchCode = ''  
    SET @DeptAdditionalInfo = ''  
    SET @DeptBankName = ''  
  END  
  
    
  SET @PinNumber  = ''  
  ------------------------------------------------------------------------  
  
  DECLARE @LSenderID int,@LReceiverID int, @WireId int, @AgSenderSeq int  
  DECLARE @InsReceiver bit, @DoItNow bit  
  DECLARE @WireDatetime datetime, @WireDate datetime  
  declare @D datetime  
  declare @IP varchar(100), @InsertPossibleFraud bit = 0  
  DECLARE @PointsAdded int  
  DECLARE @ERROR_MSG VARCHAR(MAX)  
  DECLARE @PointsTranType varchar(10)  
  
  DECLARE @StsSenderPaymentOk bit  
  DECLARE @SndFirstName  varchar(50) ,  
     @SndLast1 varchar(50) ,  
     @SndLast2  varchar(50),  
     @SndNoSecLastName bit,  
     @SndAddress varchar(200),  
     @SndState varchar(40),   
     @SndCity varchar(40),   
     @SndLastVersionId int,  
     @IsCellPhone  bit,  
     @SndEmail   varchar(100),  
     @SndZip varchar(15)  
  
  SET @WireResult = 500  
     
  
    
  SET @StsSenderPaymentOk = 0 --Este flag va siempre en 0   
  SET @RealTimeAchOK = 0  
  SET @WireReadyToChargeSender = 0  
  
  
  select @InsReceiver = 0,   
         @LReceiverID = null,  
         @WireDatetime = GETDATE(), @WireDate = dbo.DateOnly(GETDATE())  
  
BEGIN TRY    
  
  --------Sender information-------------  
  
    
  
 SELECT @SndFullName     = SndFullName ,  
        @SndFirstName    = SndFirstName,  
        @SndLast1        = SndLast1,  
        @SndLast2        = SndLast2,  
        @SndNoSecLastName= NoSecLastName,  
        @SndAddress      = SndAddress,  
        @SndState        = SndState,   
        @SndCity         = SndCity,   
        @SndCountry      = SndCountry,  
        @SndPhone        = SndPhone,  
        @SenderGroupId   = SenderGroupId,  
        @SndLastVersionId = LastVersionId,  
        @IsCellPhone      = IsCellPhone,  
        @SndEmail         = SndEmail,  
        @OptStatus        = OptStatus,  
        @SndZip           = SndZip,  
        @AgSenderState   = SndState,   
        @AgSenderCity    = SndCity,   
        @AgSenderCountry = SndCountry  
  FROM SqlMain.WireTransac.dbo.Senders  
 WHERE SenderId = @SenderId  
 if @@ROWCOUNT = 0  
     BEGIN  
  SET @WireResult  = 500  
  SET @ErrorCode = ''  
  SET @UserErrorMessage =  ''  
  SET @LogErrorMessage = 'No se Pudo Encontrar el SenderId en WireSearch '+convert(varchar, @SenderId)  
  RETURN  
  END  
   
 SELECT @LSenderID   = LSenderId  
      FROM PaymentDataEntry.dbo.Senders  
     WHERE SenderId = @SenderId  
    IF @@ROWCOUNT = 0  
    BEGIN  
      INSERT INTO Senders with(rowlock)   
         (SenderId, SenderGroupId, SndFullName, SndFirstName, SndLast1, SndLast2,   
      SndAddress, SndCountry, SndState, SndCity, SndZip,  
      SndPhone, IsCellPhone, SndLastVersionId, SndNoSecLastName,   
      SndIdTypeName, SndIdNumber, SndIdCountry, SndIdState, SndIdExpirationDate, SndEmail,OptStatus)  
           VALUES  
        (@SenderId, @SenderGroupId, @SndFullName, @SndFirstName, @SndLast1, @SndLast2,   
      @SndAddress, @SndCountry, @SndState, @SndCity, @SndZip,  
      @SndPhone, @IsCellPhone, @SndLastVersionId, @SndNoSecLastName,   
      '', '', '', '', null, @SndEmail ,@OptStatus)  
                  Set @LSenderID = SCOPE_IDENTITY()  
    END  
	ELSE BEGIN
     IF NOT EXISTS (SELECT LSenderId 
       FROM Senders with(nolock) 
      WHERE lsenderid = @LSenderID
	    and SndFullName = @SndFullName 
	    and SndFirstName = @SndFirstName 
		and SndLast1 = @SndLast1 
		and IsNull(SndLast2, '') = IsNull(@SndLast2, '') 
		and SndAddress = @SndAddress 
		and SndCity = @SndCity 
		and SndState = @SndState 
		and SndCountry = @SndCountry 
		and SndZip = @SndZip  
		and SndNoSecLastName = @SndNoSecLastName  )
		   BEGIN
		     UPDATE Senders with(updlock)
			    SET SenderId = @SenderId,     SndFullName = @SndFullName, SndFirstName = @SndFirstName,
   					SndLast1 = @SndLast1,     SndLast2 = @SndLast2,       SndAddress = @SndAddress,
   					SndCountry = @SndCountry, SndState = @SndState,       SndCity = @SndCity,
   					SndZip = @SndZip,         SndPhone = @SndPhone,       SndLastVersionId = @SndLastVersionId,
   					SndNoSecLastName = @SndNoSecLastName, IsCellPhone = @IsCellPhone, 
   					OptStatus = @OptStatus, OptStatusDate = @DateOnly
              WHERE LSenderId = @LSenderID
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
         RcvNoSecLastName, RcvLastVersionID, CPF,RcvDOB)  
   VALUES  
          (@ReceiverId, @ReceiverGroupId, @RcvFullName, @RcvFirstName,  
         @RcvLast1, @RcvLast2, @RcvAddress, @RcvCountry,  
         @RcvState, @RcvCity, @RcvZip, @RcvPhone,  
         @RcvNoSecLastName, @RcvLastVersionID, @CPF,@RcvDOB)  
  
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
             CPF = @CPF,  
    RcvDOB = @RcvDOB  
       WHERE LReceiverId = @LReceiverID      
    end   
  
--//////////////////LOYALTY  
  SET @PointsTranType = ''  
  
  IF @AcumLoyaltyPoints = 1  --Esta en el Loyalty Program  
    BEGIN  
   IF @CRMPromotionId IS NOT NULL  
  AND @CRMPromotionId <> 0  
  AND  EXISTS (Select CRMPromotionId FROM WirePricing.dbo.CRM_PointsRedemptionSetUp  --En este giro hace Redeem de puntos  
                Where CRMPromotionId = @CRMPromotionId AND Status = 'A')  
     BEGIN  
       SET @PointsTranType = 'REDEEM'  
       SET @WirePoints     = @PointsToRedeem  
    SET @WirePointsSign = -1   
     END  
      ELSE BEGIN   ---Este giro suma puntos  
         SET @PointsTranType = 'WIRE'  
        END  
 END  
  
 IF @PointsTranType = 'WIRE'  
    BEGIN   ---Este giro suma puntos  
      EXEC CRM_MakeWire_LoyaltyPointsManager @AgSenderCode ,@AgSenderSeq ,  
                                                @SameSenderId ,@TranTypeID ,'WIRE',0 ,0,@PointsAdded  OUTPUT  
      SET @WirePoints     = @PointsAdded  
   SET @WirePointsSign = 1  
    END  
  
   
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

  IF @CreditLimitcheckResult = 0
       SET @StsCreditOk = 1
  ELSE SET @StsCreditOk = 0

  
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
            NewTelewire,WireAvailableDate,   
            DiscountAmount, PromoCostToCompany, PromoCostToAgent, PromoCostToPayer, CRMPromotionId, 
			SenderPromoUniqueKey,  
            WirePoints, WirePointsSign, WiresAlreadyCountGUID,  
            SenderPaymentMethodId,WireReadyToChargeSender,WebAgentUserId,  
            UserPaymentMethodInfoId,WireIPAddress,WireFromState,IPDetectedState,WebAgentTransationId,StsSenderPaymentOk,  
            CollectionType, StsFraudCheckOk,CollectionStatus,InstantAchOK,StsCreditOk,DeviceFingerprint,
			ChannelId,PartnerId,AgPayerRcvIdTypeRecordId,RcvIdNumber) --campos nuevos del Web Agent Wire  
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
            @TranTypeID, ISNULL(@AccountNumber,''), ISNULL(@DeptBankName,''), ISNULL(@AccountType,''),  
            ISNULL(@DeptAdditionalInfo,''), ISNULL(@BankBranchCode,''), @DeliveryMethod, @SourceApp,  
            @StsComplianceOk, @StsCancel, @CustTrasactionID, @RateTypeID,@PayerPayMethodId,  
            @FeePlanID, @FxPlanID, @AgCommiPlanID, @FXDif, @FXShare_id,   
            @WirePurpose, @FundSource, @Occupation ,              
            @IncomingPhoneNumber, @CallerIDVerif, @TeledirectWire, @NoFaxBackWire,  
            @ReplacedControl, @WaivedCharges, @ReplaceWireRcvSel, @WireReplacementType, @ReplacementReasonID,  
            @MemberCardSwiped, @CreatedBy, @ComputerName, @Message, @ExRateMacro, null,@SndRcvRelationship,  
            @NewTelewire,null,  
            @DiscountAmount, @PromoCostToCompany, @PromoCostToAgent, @PromoCostToPayer, @CRMPromotionId, 
			@SenderPromoUniqueKey,  
            @WirePoints, @WirePointsSign, @WiresAlreadyCountGUID,  
            @SenderPaymentMethodId,@WireReadyToChargeSender,@WebAgentUserId,  
            @UserPaymentMethodInfoId,@WireIPAddress,@WireStateFrom,@IPDetectedState,@WebAgentTransationId,@StsSenderPaymentOk,  
            '',0,0,0,@StsCreditOk,@DeviceFingerprint,
			@ChannelId,@PartnerId,ISNULL(@AgPayerRcvIdTypeRecordId,0),ISNULL(@RcvIdNumber,''))  
  
  select @WireId = SCOPE_IDENTITY()  
  
  if @ComplianceHitsFound = 1 or @StsComplianceOk = 0  
    begin  
      UPDATE WireCompliance.dbo.Comp_WireOnHold with(updlock) Set WireId = @WireId  
      WHERE GuidId = @WebAgentTransationId  
  
   UPDATE WireCompliance.dbo.Comp_WireOnHold_DocNeeded  with(updlock) Set WireId = @WireId  
       WHERE GuidId = @WebAgentTransationId  
    end  
  
 

  --exec WireCompliance.dbo.spi_Create_CumulativeSummaryAmountsToday_DestCurrency  
  --          @WireId,  
  -- @OriAmount, @DestAmount,  
  -- @SndFullName, @OriCurrency,   
  -- @SndCountry, @AgSenderState, @AgSenderCity,  
  -- @RcvFullName, @DestCurrency,  
  -- @DestCountry, @DestState, @DestCity,  
  -- @SndPhone, @RcvPhone,  
  -- @DeptBankName, @AccountNumber, @AgPayerCode  
  
   UPDATE WebAgent_WireGeolocationInfo SET TransactionId = @WebAgentTransationId
   WHERE PreparationId = @PreparationId


  
    SET @WireResult = 0 --OK  
  COMMIT;  
  IF @PointsTranType = 'REDEEM'  
     BEGIN  
       EXEC CRM_MakeWire_LoyaltyPointsManager @AgSenderCode ,@AgSenderSeq ,  
                                              @SameSenderId ,@TranTypeID ,'REDEEM',@PointsToRedeem ,@PointsRedemptionId,@PointsAdded  OUTPUT  
     END  
    
  
   
   INSERT INTO WebAgent_CleanPreparations (PreparationId) VALUES (@PreparationId)  

   insert into WebAgent_TimeLog (WebAgentTransationId,d,pinnumber) values (@WebAgentTransationId,getdate(),@PinNumber)
  

   UPDATE SqlMain.WireTransac.dbo.WebAgent_VendorTransactions SET WebAgentTransationId = @WebAgentTransationId
    WHERE PreparationId = @PreparationId


END TRY  
BEGIN CATCH  
    IF @@TRANCOUNT > 0  
    ROLLBACK TRAN  
 DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT;  
  
    SELECT   
        @ErrorMessage = 'WebAgent_WireCreate - '+ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(),  
        @ErrorState = ERROR_STATE();  
  
    RAISERROR (@ErrorMessage, -- Message text.  
               @ErrorSeverity, -- Severity.  
               @ErrorState -- State.  
               );  
END CATCH    