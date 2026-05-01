USE [WireTransac]
GO
/****** Object:  StoredProcedure [dbo].[Wires_InsertWireTranfer_Bridge_FxRedesign]    Script Date: 6/7/2023 10:15:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Wires_InsertWireTranfer_Bridge_FxRedesign]	
	@WireId int ,
	@LSenderId int ,
	@LReceiverId int ,
	@AgSenderId int ,
	@AgSenderCode varchar(10) ,
	@AgSenderSeq int ,
	@AgSenderState varchar(80) ,
	@AgSenderCity varchar(80) ,
	@AgSenderCountry varchar(80) ,
	@AgPayerId int ,
	@AgPayerCode varchar(10) ,
	@DestCountry varchar(80) ,
	@DestState varchar(80) ,
	@DestCity varchar(80) ,
	@BranchId int ,
	@SenderId int ,
	@OnBehalfId int ,
	@ReceiverId int ,
	@SenderName varchar(150) , --150
	@OnBehalfName varchar(100) ,
	@ReceiverName varchar(150) , --150
	@PinNumber varchar(20) ,
	@WireDate datetime ,
	@WireDatetime datetime ,
	@OriAmount money ,
	@OriCurrency char(3) ,
	@Charges money ,
	@OtherChg money ,
	@AgencyFee money ,
	@AgencyExtraFee money,
	@OriToDestExRate money ,
	@WireStateFee money ,
	@WireTotalAmount money ,
	@DestAmount money ,
	@DestCurrency char(3) ,
	@AgSenderCommission money ,
	@FXPointsAdded money ,
	@FXChangeCost money ,
	@FXCostApplyTo char(1) ,
	@FeeChange money,      --
	@CostToAgent money,    --
	@CostToCustomer money, --
	@FlexPrcOptionSelected char(1),

	--CRM
	@DiscountAmount      MONEY,
    @PromoCostoToCompany MONEY,
    @PromoCostToAgent    MONEY,    
    @PromoCostToPayer    MONEY,
	@WiresAlreadyCountGUID uniqueidentifier,
	@CRMPromotionId      INT,
    @PromoUniqueKey      VARCHAR(20),

	--Loyalty
	@WirePoints int,
	@WirePointsSign int,
    @LoyaltyCardNumber varchar(50),
    
	-------------------------------

	@TranTypeID int ,
	@AccountNumber varchar(20) ,
	@DeptBankName varchar(60) ,
	@AccountType smallint ,
	@DeptAdditionalInfo varchar(60) ,
	@BankBranchCode varchar(7) ,
	@DeliveryType char(1) ,
	@SourceApp int ,
	@StsComplianceOk bit ,
	@PossibleFraud bit,
	@CustTrasactionID int ,
	@RateTypeID int ,
	@FeePlanID int ,
	@FxPlanID int ,
	@AgCommiPlanID int ,
	@FXDif money ,
	@FXShare_id int ,
	@ExRateMacro smallint ,
	
	@WirePurpose varchar(200) ,
	@FundSource varchar(120) ,
	@Occupation varchar(80) ,
	@SndEmployerName varchar(120),
	@SndEmployerPhone varchar(20),
	@SenderIdRecId int,
	
	@IncomingPhoneNumber varchar(20) ,
	@CallerIDVerif bit ,
	@TeledirectWire bit ,
	@NoFaxBackWire bit ,
	@ReplacedControl int ,
	@WaivedCharges money ,
	@ReplaceWireRcvSel int ,
	@CustMessage varchar(255) ,
	@WireReplacementType smallint ,
	@ReplacementReasonID int ,
	@MemberCardSwiped bit ,
	@SndDOB datetime ,
	@CreatedBy varchar(15) ,
	@ComputerName varchar(30) ,
	@PayerPayMethodId int ,
	@SndRcvRelationship varchar(80) ,
	@NewTelewire bit, 
	@CompReleaseDate DATETIME = null,
	@CompReleaseBy  VARCHAR(20),
	@ExclStatement bit,
	
	--Sender Information
	@SenderGroupId int ,
	@SndFirstName varchar(50) ,
	@SndLast1 varchar(50) ,
	@SndLast2 varchar(50) ,
	@SndAddress varchar(50) ,
	@SndCountry varchar(30) ,
	@SndState varchar(30) ,
	@SndCity varchar(40) ,
	@SndZip varchar(15) ,
	@SndPhone varchar(20) ,
	@SndLastVersionId int ,
	@SndNoSecLastName bit ,
	@SndEmail varchar(150),  --New x CRM
	@IsCellPhone BIT,        --New x CRM
	@OptStatus char(1),
	@OptStatusDate datetime,
	@OptStatusPromo char(1),

	
	@SndIdtypeName varchar(50),
	@SndIdNumber varchar(20),
	@SndIdCountry varchar(30),
	@SndIdState   varchar(40),
	@SndIdExpirationDate datetime,

	@F1025AgentFullName varchar(150),
	
	--Receiver Information
	@ReceiverGroupId int ,
	@RcvFirstName varchar(50) ,
	@RcvLast1 varchar(50) ,
	@RcvLast2 varchar(50) ,
	@RcvAddress varchar(200) ,
	@RcvCountry varchar(30) ,
	@RcvState varchar(30) ,
	@RcvCity varchar(40) ,
	@RcvZip varchar(15) ,
	@RcvPhone varchar(20) ,
	@RcvNoSecLastName bit ,
	@RcvLastVersionID int ,
	@CPF varchar(11),
	@AgPayerRcvIdTypeRecordId int,
	@RcvIdNumber varchar(80),
	@RcvDOB datetime,

	@WireAvailableDate datetime,

	--WebAgent
	@SenderPaymentMethodId int,
    @WireReadyToChargeSender bit,
    @WebAgentUserId int,
    @UserPaymentMethodInfoId int,
    @WireIPAddress varchar(50),
    @WireFromState varchar(40),
    @IPDetectedState varchar(40),
    @WebAgentTransationId uniqueidentifier,
	@StsCancel int, 
	@CanReasonID int,
	@StsFraudCheckOK BIT, 
    @StsSenderPaymentOK BIT , 
	@CollectionType varchar(20), 
	@StsUserKBAOk bit ,
	@WebAgentStsCreditOk bit,
	@DeviceFingerprint varchar(50), --NEW
	@PartnerId int,
    @ChannelId int,
	@StyleId int,

	--Fraud
	@FraudCheckTransacId varchar(50),
	@FraudCheckDecision varchar(10),
	@FraudCheckDecisionReason varchar(10),
	@FraudCheckScore INT,							  
	@FraudCheckDate DATETIME,

	--CardDirect
	@WireSenderPaymentMethodFee money,
	@CashBackAmount money,
	@TransacTotalAmount money,
	@CardTypeCode varchar(3),
	@LastFourOfCard varchar(4),
	@NameOnTheCard varchar(150),
	@PnRef varchar(30),
	@AuthCode varchar(20),
	@TransactionErrorCode varchar(10),
	@TransactionErrorMessage varchar(100),
	@CardDirectProviderId int,
	--FXRedesign Parameters
	@AgencyPricingId int ,
    @AgencyPricingDetailId int ,
    @FxBaseId int ,
    @FXPromotionId int ,
    @FxBase money ,
    @AgencyFXPointsFromBase money ,
    @AgencyPromoFXPoints money ,
	@FXBasePromotionId INT,
	@FxBasePromotion MONEY,
	@Citizenship VARCHAR(40),

	@Control INT OUTPUT
--	,@pO_ERROR_MSG		VARCHAR(255) OUTPUT
	
AS
BEGIN
  SET NOCOUNT ON

BEGIN TRY
  
  DECLARE @AgPayerCommission MONEY
  DECLARE @AccAgPayerCommission MONEY
  DECLARE @NewSnd BIT
  DECLARE @NewRcv BIT
  DECLARE @MaxAmountAutoReview MONEY
  DECLARE @AgDailyCommission BIT
  DECLARE @AgCurrencyCode VARCHAR(3)
  DECLARE @HQCurrencyCode varchar(3)
  DECLARE @WireAmountInv MONEY
  DECLARE @SndCommissionInv MONEY
  DECLARE @StsCreditOk BIT

  DECLARE @StsReviewed     BIT
  DECLARE @WireReviewMethod INT
  DECLARE @WireStatus INT
  DECLARE @PaidDate DATETIME
  DECLARE @SentDate DATETIME
  DECLARE @WireReviewDate DATETIME
  DECLARE @WireAgSndStatementStatus CHAR(1)
  DECLARE @ERROR_MSG VARCHAR(1000)
  DECLARE @PO_IncidentRETURN	 INT 
  DECLARE @PO_IncidentMsgError VARCHAR(100) 
  DECLARE @WireIncidentType    INT
  DECLARE @Message             VARCHAR(600)
  DECLARE @SndID INT
  DECLARE @RcvID INT
  DECLARE @AgSenderCommissionPayable MONEY
  DECLARE @FxDifAmount MONEY
  DECLARE @StsWaitForClabe bit
  DECLARE @SenderGroupId_Get INT
  DECLARE @PromotionId INT
  DECLARE @CRMPromoTranTypeId INT
  DECLARE @CRMPromoSign int
  DECLARE @PromoCode varchar(20)
  DECLARE @SameSenderId int
  DECLARE @PointsDetailApplRecordId int
  DECLARE @AssignLoyaltyCard bit = 0
  DECLARE @GatewayId int
  DECLARE @GatewayToken varchar(30)
  DECLARE @LegalEntityCode varchar(10)
  DECLARE @WebAgent bit 
  --DECLARE @WebAgencyRunOutCredit BIT = 0
  DECLARE @SameSenderIdWeb int
  DECLARE @WhichSystemApp varchar(20) = ''
  DECLARE @AgAssociationCommission money = 0
  DECLARE @Step int = 0
  DECLARE @AgCashDirect BIT

  --for charges and fx validation
  DECLARE	@pO_FeeAmount			MONEY , -- Importe de fee (Wires.charges)
	@pO_CommissionAmount	MONEY , -- Importe de comision
	@pO_OriToDestExRate		MONEY , -- Tipo de cambio entre moneda origen y moneda destino (plan de tipo de cambio Prc_ExRatePlanDetail.ExRate)
	@pO_DestAmount			MONEY , -- Importe del giro expresado en moneda destino
	@pO_FeePlanID			INT   ,		  -- Código de tipo de plan de tarifa
	@pO_CommPlanID			INT   ,		  -- Código de tipo de plan de comisión
	@pO_RatePlanID			INT   ,		  -- Código de tipo de plan de tipo de cambio
	@pO_Message				VARCHAR(200), 	-- Mensaje de retorno
    @pO_FXDif				MONEY ,
    @pO_FXShareId			INT   ,
    @pO_WireStateFee        MONEY ,
	@ValidOK                BIT

  declare @today datetime
  DECLARE @InsDupIncident bit = 0
  set @today = dbo.DateOnly(getdate()) 

  declare @D datetime
  declare @IP varchar(100)
  
  set @D = GETDATE()
  Set @IP =  dbo.GetCurrentIP()  

  IF @DiscountAmount IS NULL
     SET @DiscountAmount = 0

  
 -- insert into debug (agencyid,s,d,t) values (0,'este',getdate(),null )

     
  --if exists (Select * from AgSenders
  --          where agencycode = @AgSenderCode
  --            and WebAgent = 1)
  --        SET @WebAgent = 1
  --   else SET @WebAgent = 0

  	Select @WebAgent = ISNULL(WebAgent,0),
	       @AgCashDirect = CashDirect
	  from AgSenders
     where agencycode = @AgSenderCode

   if @SourceApp in (6,46) --Cash Direct or payment platform
     set @AgCashDirect = 1

   if @WebAgent = 1
     Set @WhichSystemApp = 'WEBAGENT'
   else if @CanReasonID = 57 --CARD DIRECT - COLLECTION FAIL
     Set @WhichSystemApp = 'CardDirect'
   else
     Set @WhichSystemApp = @CreatedBy

   IF (@WebAgent = 1)
     AND (EXISTS (Select * FROM WebAgent_Wires
	              Where WebAgentTransationId = @WebAgentTransationId))
	BEGIN
	    SELECT @Control = Control
		FROM WebAgent_Wires
	    WHERE WebAgentTransationId = @WebAgentTransationId
		RETURN
	END

  IF @WebAgent = 0 --No es web agent
     BEGIN
	   SET @StsFraudCheckOK = 1
	   SET @StsCancel = IsNull(@StsCancel, 0)
	   SET @StsUserKBAOk = 1
	   
	 END

--  insert into Temp(Msg) values('CENPOS')


  IF @SenderPaymentMethodId IS NULL --New x card direct
  OR @SenderPaymentMethodId = 0
     begin
		 SET @StsSenderPaymentOK = 1
		 SET @SenderPaymentMethodId = 1 --Cash
	 end

  if (len(rtrim(@LoyaltyCardNumber)) >= 8)
    begin  ---Tiene loyalty card
		if (@SenderId is null or @SenderId = 0)  --Sender Nuevo
		   begin
			  Set @AssignLoyaltyCard = 1
			end
		else if @SenderId > 0                    --Sender Existente
			begin
			  if (not Exists(select * from CRM_SenderLoyaltyCards where CardNumber = @LoyaltyCardNumber))
				  begin  -- NO existe el sender con ese loyalty card
					Set @AssignLoyaltyCard = 1
				  end
			  else if ISNULL(@SameSenderId,0) = 0 --Sender Existente pero SameSenderId = 0
				  begin
				    Set @AssignLoyaltyCard = 1
				  end
			end 
    end
   else 
    begin  --Loyalty card viene en blanco, Sender Existente pero SameSenderId = 0 ==> pero me fijo x sender id si tiene una
	  if @SenderId > 0 and ISNULL(@SameSenderId,0) = 0
		 begin
		   if Exists(select * from CRM_SenderLoyaltyCards where SenderId = @SenderId )
			  begin
			    Set @AssignLoyaltyCard = 1
			  end
		 end
	end


  INSERT INTO SP_WireLog with(rowlock)
		   (AgSenderCode, AgSenderSeq, SenderName,ReceiverName,OriAmount,AgPayerCode,CreatedBy,WireDateTime,ComputerName,
		    IPAddress, SP)
	 VALUES
		   (@AgSenderCode,@AgSenderSeq, @SenderName,@ReceiverName,@OriAmount,@AgPayerCode,@CreatedBy,@D,@ComputerName,
		    @IP, @SourceApp)

--  SET @pO_ERROR_MSG		= ''
  SET @ERROR_MSG        = ''
  SET @Control          = 0

  select @PaidDate = NULL, 
         @Sentdate = NULL, 
         @WireReviewDate = NULL,
         @SenderName = dbo.fn_RemoveDupSpaces(ltrim(rtrim(@SenderName))),
         @ReceiverName = dbo.fn_RemoveDupSpaces(ltrim(rtrim(@ReceiverName)))
  
  SELECT @AccountType = ISNULL(@AccountType, 0)
  
/*  SELECT @Control = Control
    FROM Wires
   WHERE AgSenderCode = @AgSenderCode
     AND AgSenderSeq  = @AgSenderSeq
  If @@ROWCOUNT = 1
     return
*/     
--  begin tran;
  
  declare @m varchar(150)
  
  if exists(select *
            from Wires
            where AgSenderId = @AgSenderId and AgSenderSeq = @AgSenderSeq)
   begin
     SET @m = 'AgId:' + cast(@AgSenderId as varchar) + ' Seq: ' + CONVERT(varchar,@AgSenderSeq) + ' Duplicated Sender Agency Seq. Number.'
     RAISERROR (@m, 16, 1)
     return
   end
  
  if rtrim(ltrim(@DestCountry)) <> rtrim(ltrim(@RcvCountry))
	SELECT @DestCountry = BrCountry
	FROM Branches
	WHERE BranchID = @BranchId
    
  SELECT @AgDailyCommission = AgDailyCommission,
         @AgCurrencyCode    = AgCurrencyCode
    FROM AgSenderAccounting
   WHERE AgencyId = @AgSenderId

  SELECT @HQCurrencyCode = CurrencyCode
    FROM LegalEntities
   WHERE LegalEntityStatus ='A'
     AND LegalEntityType = 'HQ'

  SELECT @LegalEntityCode = LegalEntityCode
	FROM Agencies 
   WHERE AgencyCode = @AgSenderCode
 
  IF (@SenderId = 0) OR (NOT Exists(SELECT * FROM Senders  WHERE SenderID = @SenderID))
     BEGIN
		Set @SndID = null
		select @SndID = SenderId 
		  from SendersCrossReference
		 where LSenderId = @LSenderId
		if @SndID is not null
		  if Exists(select * from Senders with(nolock) where SenderID = @SndID)
			 begin
			   set @SenderId = @SndID
			   SELECT @SndLastVersionId = LastVersionId
                 FROM Senders
                WHERE SenderId = @SenderId
			 end
     END
       
  SET @NewSnd = 0
  IF (@SenderId = 0)
     BEGIN
         EXECUTE Senders_Create_CRM_Fase2     @WireDate,
									@SndFirstName,
									@SndLast1,
									@SndLast2,
									@SndAddress,
									@SndCountry,
									@SndState,
									@SndCity,
									@SndZip,
									@SndPhone,
									@CreatedBy,
									@SndNoSecLastName,
									1,
									@SndEmail ,
	                                @IsCellPhone ,
									0      ,
									@Citizenship,
									''  ,
									null              ,
									@SenderId OUTPUT,
									@SndLastVersionId OUTPUT,
									@SenderGroupId OUTPUT
	    SET @NewSnd = 1
       END
  ELSE BEGIN
        SELECT @SndLastVersionId = LastVersionId
          FROM Senders with(nolock) 
         WHERE SenderId     = @SenderId
           and SndFullName  = @SenderName
           and SndFirstName = @SndFirstName 
           and SndLast1     = @SndLast1 
           and SndLast2     = @SndLast2 
           and SndAddress   = @SndAddress 
           and SndCity      = @SndCity 
           and SndState     = @SndState 
           and SndCountry   = @SndCountry 
           and SndZip       = @SndZip 
           and SndPhone     = @SndPhone
        IF @@ROWCOUNT = 0
		OR (@SndEmail IS NOT NULL AND @SndEmail <> '')
		OR (@IsCellPhone is not null)
             BEGIN
               EXECUTE @SndLastVersionId = Senders_Update_CRM_V1
                                    @WireDate,
									@SenderId,
									@SndFirstName,
									@SndLast1,
									@SndLast2,
									@SndAddress,
									@SndCountry,
									@SndState,
									@SndCity,
									@SndZip,
									@SndPhone,
									@SndNoSecLastName,
									1,
									@SndEmail ,
	                                @IsCellPhone ,
									@CreatedBy,
									@Citizenship		
             
             END  
         ELSE BEGIN
                IF (@SndLastVersionId IS NULL)
                OR (@SndLastVersionId = 0)
                   SET @SndLastVersionId = 1
              END
            
       END
       -- IF (RTRIM(ISNULL(@SndIdTypeName,'')) <> '') 
       --AND (RTRIM(ISNULL(@SndIdNumber,'')) <> '')
       --AND (@SenderGroupId IS NOT NULL)
       --AND (@SenderGroupId <> 0)
	      -- BEGIN
	      --   EXEC Comp_SenderIds_InsertNotVerified  @SenderGroupId ,  @NewSnd,
	      --                                          @SndIdTypeName ,  @SndIdNumber,     
	      --                                          @SndIdCountry ,   @SndIdState ,     
	      --                                          @SndIdExpirationDate ,@AgSenderCode
	       
	      -- END 
	    IF (RTRIM(ISNULL(@SndIdTypeName,'')) <> '') AND (RTRIM(ISNULL(@SndIdNumber,'')) <> '')
	       BEGIN
	         SELECT @SenderGroupId_Get = SenderGroupId 
	           FROM Senders
	          WHERE SenderId = @SenderId
	         IF  (@SenderGroupId_Get IS NOT NULL)
             AND (@SenderGroupId_Get <> 0)
                 BEGIN
					 EXEC Comp_SenderIds_InsertNotVerified  @SenderGroupId_Get ,  @NewSnd,
															@SndIdTypeName ,  @SndIdNumber,     
															@SndIdCountry ,   @SndIdState ,     
															@SndIdExpirationDate ,@AgSenderCode
	              END
	       
	       END 


    if not Exists(select * from SendersCrossReference with(nolock) 
                   where LSenderId = @LSenderID)
       BEGIN
			INSERT INTO SendersCrossReference with(rowlock) (LSenderId, SenderID) 
													 VALUES (@LSenderID, @SenderID)
       END
                                             
      
 

	--if (@OptStatus is not null  or @OptStatusPromo IS NOT NULL)
	--and Exists(select * from Senders where SenderId = @SenderId and (IsNull(OptStatus, '') <> @OptStatus OR IsNull(OptStatusPromo, '') <> @OptStatusPromo))
 --     update Senders with(updlock) 
 --          Set OptStatus = @OptStatus, OptStatusDate = @OptStatusDate,OptStatusPromo = ISNULL(@OptStatusPromo,'')
 --     where SenderId = @SenderId
    
	  
-- lo mismo para receiver
  IF (@ReceiverId = 0)
  OR (NOT Exists(SELECT * FROM Receivers  WHERE ReceiverId = @ReceiverId))
       BEGIN
			Set @RcvID = null
			select @RcvID = ReceiverId 
			  from ReceiversCrossReference
			 where LReceiverId = @LReceiverId
			if @RcvID is not null
			  if Exists(select * from Receivers with(nolock) where ReceiverId = @RcvID)
				 begin
				   set @ReceiverId = @RcvID
				   SELECT @RcvLastVersionId = LastVersionId
                     FROM Receivers
                    WHERE ReceiverId = @ReceiverId
				 end
       END
  
  
  select @NewRcv = 0, 
         @CPF = ISNULL(@CPF,''),
		 @RcvPhone = IsNull(@RcvPhone, ''),
		 @RcvIdNumber = isnull(@RcvIdNumber,''),
		 @AgPayerRcvIdTypeRecordId = isnull(@AgPayerRcvIdTypeRecordId,0)


  IF @ReceiverId = 0
        BEGIN
          EXEC Receivers_Create     @CreatedBy,
									@RcvFirstName,
									@RcvLast1,
									@RcvLast2,
									@RcvAddress,
									@RcvCountry,
									@RcvState,
									@RcvCity,
									@RcvZip,
									@RcvPhone,
									@RcvNoSecLastName,
									1,
									@CPF,
									@ReceiverId OUTPUT,
									@RcvLastVersionID OUTPUT
		 SET @NewRcv = 1
       END
  ELSE BEGIN
          
          SELECT @RcvLastVersionID = LastVersionID 
            FROM Receivers with(nolock)
           WHERE ReceiverID   = @ReceiverID 
             and RcvFirstName = @RcvFirstName 
             and RcvLast1     = @RcvLast1 
             and RcvLast2     = @RcvLast2 
             and RcvAddress   = @RcvAddress 
             and RcvCity      = @RcvCity 
             and RcvState     = @RcvState 
             and RcvCountry   = @RcvCountry 
             and RcvZip       = @RcvZip 
             and RcvPhone     = @RcvPhone 
             and CPF          = @CPF
           IF @@ROWCOUNT = 0  
             BEGIN
               EXECUTE @RcvLastVersionID = Receivers_Update
									@ReceiverId,
									@RcvFirstName,
									@RcvLast1,
									@RcvLast2,
									@RcvAddress,
									@RcvCountry,
									@RcvState,
									@RcvCity,
									@RcvZip,
									@RcvPhone,
									@RcvNoSecLastName,
									@CreatedBy	,
									1	,
									@CPF
            END
         ELSE BEGIN
                IF (@RcvLastVersionID IS NULL)
                OR (@RcvLastVersionID = 0)
                   SET @RcvLastVersionID = 1
              END

       END

	

	--Arreglo de Bancolombia porque estamos cansadas de arreglarlo a mano
	IF @Agpayercode = 'CL-020' and @TrantypeId = 3 and @AccountType = 0  
   begin
     if @NewRcv = 1
	    BEGIN
	      SET @AccountType = 8
		END
	 ELSE BEGIN
	       SELECT top 1 @AccountType = BankAccType
		     FROM Wires
			WHERE ReceiverId  = @ReceiverId
			  and AgPayerCode = @Agpayercode
			  and TrantypeId  = 3
			  and wirestatus  = 4
			Order by Control desc
			If @AccountType = 0
			   SET @AccountType = 8
	      END
	    
   end

    if not Exists(select * from ReceiversCrossReference with(nolock) 
                   where LReceiverId = @LReceiverID)
       BEGIN
			INSERT INTO ReceiversCrossReference with(rowlock) (LReceiverId, ReceiverID) 
													   VALUES (@LReceiverID, @ReceiverId)
       END
    
---Multimoneda
	DECLARE @OriToAccExRate MONEY
	DECLARE @AccAmount  MONEY
	DECLARE @AccToDestExRate MONEY

	---Multimoneda: Convierto  @AgPayerCommission a Moneda Origen
		
	SET @OriToAccExRate = dbo.GetExRate2019 (@OriCurrency,@HQCurrencyCode)
	SET @AccAmount      = @OriAmount * @OriToAccExRate
	SET @AccToDestExRate = ROUND( @DestAmount / @AccAmount,4)
   
 
   IF @WirereplacementType = 2
     SET @AgPayerCommission = 0
  ELSE 
     --EXECUTE Wires_GetCostPerWire @AgPayerId, @TranTypeID, @DestCurrency, @OriAmount,@OriCurrency, @AgPayerCommission OUTPUT
	   EXECUTE Wires_GetCostPerWire @AgPayerId, @TranTypeID, @DestCurrency, @AccAmount,@OriCurrency, @AgPayerCommission OUTPUT

  SET @AccAgPayerCommission = @AgPayerCommission
  IF @OriToAccExRate <> 1
     SET @AgPayerCommission = @AgPayerCommission /@OriToAccExRate

	 ----------------------------------------------------------------------------

  if (@AssignLoyaltyCard = 1)  --This is done only for new senders o senders que se les asigno la tarjeta en el search de cash direct
 and (ISNULL(@WirePointsSign,0) = 0 OR @WirePointsSign = 1 )
    begin 
	  SELECT @WirePoints  = Points  
	   FROM SqlDataentry.WirePricing.dbo.CRM_LoyaltyPointsSetUp
      WHERE TranTypeID = @TranTypeID

	  SET @WirePointsSign = 1
    end

  Set @Step = 10
  BEGIN TRANSACTION

		EXEC GetNextControl @Control output

		if (@OptStatus is not null  or @OptStatusPromo IS NOT NULL)
	   and Exists(select * from Senders where SenderId = @SenderId and (IsNull(OptStatus, '') <> @OptStatus OR IsNull(OptStatusPromo, '') <> @OptStatusPromo))
		   update Senders with(updlock) 
			  Set OptStatus        = @OptStatus, 
			      OptStatusDate    = @OptStatusDate,
				  OptStatusPromo   = ISNULL(@OptStatusPromo,''),
				  OptStatusControl = @Control
		    where SenderId = @SenderId
		
		IF @AgDailyCommission = 1 and @SenderPaymentMethodId <> 5 --Card Direct
             BEGIN
               SET @WireAmountInv    = @OriAmount + @Charges + @OtherChg + @WireStateFee -  @AgSenderCommission 
               SET @SndCommissionInv = @AgSenderCommission
             END
        ELSE BEGIN
               SET @WireAmountInv    = @OriAmount + @Charges + @OtherChg + @WireStateFee + ISNULL(@WireSenderPaymentMethodFee,0)- @PromoCostToAgent  --=========CRM 
               SET @SndCommissionInv = 0 
             END

        ---Verif Credit
        IF (@WireReplacementType <> 2 ) and (@TranTypeID <> 6)  and (@SenderPaymentMethodId <> 5) 
		--No es reemplazo, No es webagent y no es Bill Payment y no es CardDirect
            BEGIN
				--EXECUTE Agencies_VerifyAgCredit
				EXEC Agencies_VerifyAgCredit_No_hold  --Si es webagent esta funcion no suspende la agencia solo envia email de alerta
											@pI_Control       = @Control,
											@pI_AgencyID      =	@AgSenderId, 
											@pI_WireAmountInv =	@WireAmountInv, 
											@pI_StsCreditOk   = @StsCreditOk OUTPUT--,
											--@PO_WebAgencyRunOutCredit = @WebAgencyRunOutCredit OUTPUT
		    END
		ELSE SET @StsCreditOk = 1

		IF @WebAgent = 1
		   BEGIN
		     SET @StsCreditOk = @WebAgentStsCreditOk
		   END



        --------------- StsReview
        SET @StsReviewed      = 0
        SET @WireReviewMethod = 0

        IF (@SourceApp in ( 6,46)) --Cash Direct
        OR (@SourceApp = 8) --Online systems
		OR (@SourceApp = 37) --WebAgent
		OR (@SourceApp = 58) -- Mobile App
             BEGIN
			  insert into _debug (watch) values (concat('Wires_InsertWireTranfer_Bridge_FxRedesign: SourceApp: ', @SourceApp, ' Reviewed: ', @StsReviewed, ' PinNumber: ', @PinNumber))
               SET @StsReviewed = 1
               SET @WireReviewDate = GETDATE()
             END
        ELSE BEGIN --Telewire
               IF (@WireReplacementType = 2 )--Replacement Wire
                  BEGIN
				   DECLARE @Str varchar(20)
				   SET @Str = dbo.fnc_Get_configParam('MaxAmountAutoReview')
				   SET @MaxAmountAutoReview	= CONVERT(decimal(17,2),@Str)
		           
				   IF ( @AccAmount < @MaxAmountAutoReview )
					   BEGIN
			   			 SET @StsReviewed = 1
						 SET @WireReviewMethod = 6
						 SET @WireReviewDate = GETDATE()
					   END
			       END
             END

         --Check for duplicate wire    
         IF @SourceApp not in ( 6,46) and -- No check for Cashdirect
		     Exists(SELECT * FROM Wires with(nolock)
                    WHERE AgSenderID   = @AgSenderID 
                      AND StsCancel    = 0 
                      AND WireDate     = @Today
                      AND SenderName   = @SenderName 
                      AND ReceiverName = @ReceiverName )
             BEGIN
			  -- insert into debug (agencyid,s,d) values (@Control,'dup',getdate()) 
               SET @StsReviewed    = 0
               SET @WireReviewDate = NULL
			   SET @InsDupIncident = 1
             END
                      
       -----New Wait for clabe-----------
		Set @StsWaitForClabe = 0
		 if (@TranTypeID = 3) --Deposit
		and (exists (Select * from AgPayers where AgencyCode = @AgPayerCode and DepositNeedClabe = 1))
			begin
			  if LEN(RTRIM(@AccountNumber)) <> 16 --Tarjetas tienen 16 y estan ok
				 begin
				   IF dbo.fn_IsClabeValid(@AccountNumber) = 0
				      begin
					    set @StsWaitForClabe = 1
					    insert into SyncDataSrc with(rowlock) (TableName,TableID) values('Wires_StsWaitForClabe',@Control) --Tabla para el reporte de Alerta
					  end
				 end
	        
			end
  
       ----------Wire Status
      Set @WireStatus = 1
      
	  IF @TranTypeID <> 6 --Not bill payment
		   BEGIN 
			 IF @StsReviewed = 1 
			AND @StsCreditOk = 1 
			AND @StsComplianceOk = 1 
			AND @WireReplacementType <> 2
			AND @StsWaitForClabe = 0  
			AND @StsSenderPaymentOK = 1
			AND @StsFraudCheckOK = 1
			AND @StsUserKBAOk = 1
			   Set @WireStatus = 2     
		   END
	  ELSE BEGIN   
			 SET @WireStatus  = 4
			 SET @StsReviewed = 1
			 SET @PaidDate = GETDATE()  --Bill Payment is created as already paid
			 SET @SentDate = GETDATE()
           END

	  IF (@NewSnd = 1) OR (@NewRcv = 1)
	   BEGIN
		  EXEC SenderReceiverLastWire_Create_RcvId  @SenderId ,
											  @ReceiverId ,
									 		  @Control ,
											  @TranTypeId ,
											  @AgPayerId ,
											  @AgPayerCode ,
									 		  @BranchId ,
											  @DeliveryType ,
											  @DestCurrency,
									 		  @PayerPayMethodId ,
											  @AccountNumber ,
											  @DeptBankName ,
											  @AccountType ,
											  @BankBranchCode ,
											  @DeptAdditionalInfo ,
											  @RateTypeID ,
											  @AgPayerRcvIdTypeRecordId,
											  @RcvIdNumber
		END
	  ELSE 
	    BEGIN
			EXEC SenderReceiverLastWire_Update_RcvId    @SenderId ,
												  @ReceiverId ,
												  @Control ,
												  @TranTypeId ,
												  @AgPayerId ,
												  @AgPayerCode ,
												  @BranchId ,
												  @DeliveryType,
												  @DestCurrency ,
												  @PayerPayMethodId ,
												  @AccountNumber,
												  @DeptBankName,
												  @AccountType,
												  @BankBranchCode,
												  @DeptAdditionalInfo,
												  @RateTypeID ,
												  @AgPayerRcvIdTypeRecordId,
											      @RcvIdNumber
		END

    IF NOT EXISTS ( SELECT * 
                      FROM SenderAgencies 
					 WHERE SenderId = @SenderId 
                       AND AgencyId = @AgSenderId )
		BEGIN
			INSERT INTO SenderAgencies with(rowlock) (SenderId, AgencyId, AgencyCode)
			VALUES (@SenderId, @AgSenderId, @AgSenderCode)
		END

	IF @SenderPaymentMethodId <> 5  
	   SET @AgSenderCommissionPayable = @AgSenderCommission - @SndCommissionInv 
	ELSE 
	   SET @AgSenderCommissionPayable = @AgSenderCommission --Card Direct

	IF @AgSenderCommissionPayable > 0  --- CRM
	   SET @AgSenderCommissionPayable = @AgSenderCommissionPayable - @PromoCostToAgent

	if @AgPayerCode = 'HO-05' and rtrim(@DeptBankName) = ''
		begin
		  select @DeptBankName = BrPlaceName
			from Branches with(nolock)
		   where BranchId = @BranchId
		end

	--Referencia cruzada de datos de PaymentDataEntry / WireTransac
	IF NOT EXISTS (SELECT * FROM WiresCrossReference with(nolock) WHERE WireID = @WireId)
	BEGIN
		INSERT INTO WiresCrossReference with(rowlock) (WireID, Control, Entered)
		VALUES (@WireId, @Control, GETDATE())			
	END

	 
    EXEC dbo.AgAssociationCommission_Calculate @AgSenderCode,@Charges,@AgAssociationCommission  OUTPUT

	SET @ERROR_MSG = ''
	INSERT INTO Wires with(rowlock)
		   (Control              ,AgSenderId             ,AgSenderCode              ,AgSenderSeq
		   ,AgPayerCode          ,AgPayerId              ,AgPayerSeq                ,SenderId
		   ,SndVersionId         ,SndSequence            ,DaysFromLastWire          ,OnBehalfId
		   ,OnBehalfVersionId    ,ReceiverId             ,RcvVersionId              ,SenderName           
		   ,OnBehalfName         ,ReceiverName           ,BranchId                  ,PinNumber
		   ,WireDate             ,WireDatetime           ,OriAmount                 ,OriCurrency
		   ,Charges              ,OtherChg               ,OriToDestExRate           ,DestAmount
		   ,DestCurrency         ,WireTotalAmount        ,WireAmountInv             ,WireStateFee
		   ,AgSenderCommission   ,AgSenderCommissionInv  ,AgSenderCommissionPayable ,AgPayerCommission
		   ,AgencyFee            ,FXPointsAdded          ,FXChangeCost              ,FXCostApplyTo
		   ,RateTypeID           ,TranTypeID             ,DestCountry               ,DestState
		   ,DestCity             ,AccountNumber          ,DeptBankName              ,AccountTypeId
		   ,DeptAdditionalInfo   ,DeliveryType           ,PayerPayMethodId          ,SourceApp
		   ,TeledirectWire       ,WireStatus             ,StsReviewed               ,StsCreditOk
		   ,StsComplianceOk      ,StsCancel              ,ReqCancel                 ,ReqNameChange
		   ,WireReviewMethod     ,WireReviewDate         ,WireReleaseBy             ,WireReleaseDate
		   ,SentDate             ,PaidDate               ,ActualPaymentBranch       ,CanReasonID
		   ,CancelDate           ,CancelBy               ,CreatedBy                 ,ComputerID
		   ,IncomingPhoneNumber  ,CallerIDVerif          ,WireEdited                ,WireUpdated
		   ,SentFileId           ,NoFaxBackWire          ,BankBranchCode            ,BankAccType
		   ,WireReplacementType  ,ReplacementOk          ,MemberCardSwiped          ,FXGain
		   ,GrossMargin          ,StsWaitForClabe        ,PossibleFraude            ,WireAvailableDate
		   ,DiscountAmount       ,PromoCostToCompany     ,PromoCostToAgent         ,PromoCostToPayer
		   ,PromoCostToAgentJE   ,WirePoints             ,WirePointsSign           ,PointsApplied 
		   ,StsSenderPaymentOK   ,SenderPaymentMethodId  ,StsFraudCheckOK         ,StsUserKBAOk
		   ,AgencyExtraFee       ,SenderPaymentMethodFee ,CashBackAmount          , AgAssociationCommission
		   ,AgPayerRcvIdTypeRecordId ,RcvIdNumber            ,F1025AgentFullName)
		   
		VALUES 
		(
			@Control, 		           @AgSenderId,  		     @AgSenderCode,		          @AgSenderSeq,
			@AgPayerCode,  	           @AgPayerId, 		         0,			                  @SenderId,
			@SndLastVersionId,  	   0,  		                 0,  	                      IsNull(@OnBehalfId, 0),
			0                 ,        @ReceiverId,		         @RcvLastVersionID,	  	      @SenderName,
			ISNULL(@OnBehalfName,''),  @ReceiverName,	         @BranchId, 			      @PinNumber,
			@WireDate,  		       @WireDatetime,		     @OriAmount,			      @OriCurrency,
			@Charges,		           @OtherChg,                @OriToDestExRate,		      @DestAmount,
			@DestCurrency,	           @WireTotalAmount, 	     @WireAmountInv,		      @WireStateFee,
			@AgSenderCommission,       @SndCommissionInv,        @AgSenderCommissionPayable,  @AgPayerCommission,
			@AgencyFee,                @FXPointsAdded ,          @FXChangeCost  ,             @FXCostApplyTo ,
			@RateTypeID,			   @TranTypeID,  		     @DestCountry,     	          @DestState,
			@DestCity,			       @AccountNumber,		     @DeptBankName,		          @AccountType,
			@DeptAdditionalInfo,	   @DeliveryType,	         @PayerPayMethodId, 	      @SourceApp,
			@TeledirectWire,		   @WireStatus,			     @StsReviewed,			      @StsCreditOk,
			@StsComplianceOk,	       0,			             0,                           0,
			@WireReviewMethod,	       @WireReviewDate,		     @CompReleaseBy,              @CompReleaseDate,        
			@SentDate,			       @PaidDate,                '',                          0,
			NULL,         			   '',                       @CreatedBy,                  @ComputerName,
			@IncomingPhoneNumber,      @CallerIDVerif,           0,                           NULL,
			0,                         @NoFaxBackWire  ,         @BankBranchCode  ,           @AccountType ,
			@WireReplacementType,0,                              @MemberCardSwiped,           0,
			0		                  ,@StsWaitForClabe,         @PossibleFraud              ,@WireAvailableDate
			,@DiscountAmount          ,@PromoCostoToCompany     ,@PromoCostToAgent           ,@PromoCostToPayer
			,@PromoCostToAgent        ,@WirePoints              ,@WirePointsSign             ,0
			,@StsSenderPaymentOK      ,@SenderPaymentMethodId   ,@StsFraudCheckOK,           @StsUserKBAOk
			,@AgencyExtraFee          ,@WireSenderPaymentMethodFee,@CashBackAmount ,         @AgAssociationCommission
			,@AgPayerRcvIdTypeRecordId ,@RcvIdNumber            , @F1025AgentFullName)
			

        if (@FXPointsAdded <> 0) or (@FXChangeCost <> 0) or (@FeeChange <> 0) or (@CostToAgent <> 0) or (@CostToCustomer <> 0)
          insert into dbo.WireFlexPrc with(rowlock) (Control, FXPointsAdded, FXChangeCost, FXCostApplyTo, FeeChange, CostToAgent, CostToCustomer, FlexPrcOptionSelected)
                                             values(@Control, @FXPointsAdded, @FXChangeCost, @FXCostApplyTo, @FeeChange, @CostToAgent, @CostToCustomer, @FlexPrcOptionSelected)

		IF @StsCancel = 1
 		  BEGIN					  
		   DECLARE @ErrorCode varchar(10)
		   EXEC WireCancels_CancelSelectedWire @Control, @CanReasonID, @WhichSystemApp, 1, 0, 0, @ErrorCode OUTPUT
		  END

		IF @WebAgent = 1 --Web Agent Wires
		   BEGIN
		    SELECT @GatewayToken = GatewayToken,
			       @GatewayId    = GatewayId
			  FROM WebAgent_UserPaymentMethodInfo
			 WHERE UserPaymentMethodInfoId = @UserPaymentMethodInfoId

			UPDATE WebAgent_UserPaymentMethodInfo SET LastTransactionDate = getdate()
			 WHERE UserPaymentMethodInfoId = @UserPaymentMethodInfoId

		

			INSERT INTO WebAgent_Wires  (Control                           ,WireDate                        ,WebAgentUserId
                                         ,UserPaymentMethodInfoId           ,WireIPAddress                   ,WireReadyToChargeSender
                                         ,SenderPaymentProcessDate          ,SenderPaymentConfirmationDate   ,WireFromState
                                         ,AchFileId                         ,IPDetectedState                 ,WebAgentTransationId
                                         ,LogChangeInfoId                   ,FraudCheckTransacId             ,FraudCheckDecision
                                         ,FraudCheckDecisionReason          ,FraudCheckScore                 ,FraudCheckDate
										 ,GatewayId                         ,GatewayToken
                                         ,CollectionType                    ,CollectionStatus                ,CollectionStatusDate
                                         ,CollectionTransacID               ,CollectionErrorCode             ,CollectionAuthCode
                                         ,CollectionProcessedAs             ,LegalEntityCode                 ,DeviceFingerprint
										 ,PartnerId                         ,ChannelId                       ,StyleId)
				                 VALUES (@Control                       ,@WireDate,                @WebAgentUserId           
								        ,@UserPaymentMethodInfoId       ,@WireIPAddress           ,@WireReadyToChargeSender  
										,null                           ,null                     ,@WireFromState            
										,0                              ,@IPDetectedState         ,@WebAgentTransationId
										,0                              ,@FraudCheckTransacId     ,@FraudCheckDecision
										,@FraudCheckDecisionReason      ,@FraudCheckScore         ,getdate()
										,@GatewayId                     ,@GatewayToken
										,@CollectionType                ,0                        ,null
										,0                              ,''                       ,''
										,''                             ,@LegalEntityCode         ,@DeviceFingerprint
										,@PartnerId                     ,@ChannelId               ,@StyleId) --channel y partner estan dados vuelta porque el codigo delphi esta mal!!!
										                                                --cuando arreglemos el codigo fuente hay que ponerlos bien otra vez!
				 

			IF @stsCancel = 0 AND @WireStatus = 1 --WebAgent - El giro no esta listo para ser enviado (retenido x algo)
			   BEGIN
			     INSERT INTO WiresToNotifyAvailability (Control) VALUES(@Control)
			   END

            IF @StsSenderPaymentOK = 1
			   INSERT INTO WebAgent_ProcessFee_ToCalculate (Control) VALUES(@Control)

			UPDATE WebAgent_VendorTransactions WITH(UPDLOCK) SET Control = @Control
			 WHERE WebAgentTransationId = @WebAgentTransationId

            SELECT @SameSenderIdWeb = s.SameSenderId 
   	          FROM Senders as s
				   INNER JOIN Crm_SameSenders as ss on s.SameSenderId = ss.SameSenderId and ss.FirstWireDate is null
			 WHERE s.SenderId = @SenderId
			IF @@ROWCOUNT = 1
			   BEGIN
			     update CRM_SameSenders set FirstWireDate =@WireDate
				  Where SameSenderId = @SameSenderIdWeb
			        and  FirstWireDate IS NULL
			   END

			INSERT INTO dbo.WebAgent_WireOriginalStatus  (Control            ,WireStatus           ,StsCancel
                                                         ,StsFraudCheckOK    ,StsCreditOk          ,StsUserKBAOk
                                                         ,StsComplianceOk    ,StsReviewed          ,WireCreated, StsSenderPaymentOK)
                                                 VALUES (@Control           ,@WireStatus          ,@StsCancel
                                                        ,@StsFraudCheckOK   ,@StsCreditOk         ,@StsUserKBAOk
                                                        ,@StsComplianceOk   ,@StsReviewed         ,getdate() , @StsSenderPaymentOK)


		   END

		IF @InsDupIncident = 1
			EXEC Inc_AutomaticWireIncident_Create @Control ,'DUPLICATE_WIRE' ,0 ,'Por favor verificar que el giro no sea duplicado' ,'SYSTEM' 

                  
        IF @ReplacedControl <> 0
        BEGIN
			INSERT INTO WireReplacements with(rowlock)
					   (NewControl        ,ReplacedControl        ,WaivedCharges
					   ,UserName          ,Created                ,ReplacementReasonId
					   ,RcvSelection)
				 VALUES(@Control		  ,@ReplacedControl       ,@WaivedCharges	    ,
						@CreatedBy  	  ,GETDATE()		    ,ISNULL(@ReplacementReasonID, 1),
						@ReplaceWireRcvSel)

            UPDATE Wires Set WireReplacementType = 1 Where Control = @ReplacedControl

		    set @WireIncidentType = dbo.fnc_Get_configParam('ReqActionClosed')
		    -- set @Message = 'Giro sin cargo por reemplazo del giro ' + Convert(varchar, @ReplacedControl)  + ' Monto ' + Convert(varchar, @WaivedCharges)
		    if @WaivedCharges > 0
			   BEGIN
				set @Message = 'Giro sin cargo por reemplazo del giro ' + Convert(varchar, @ReplacedControl)  + ' Monto ' + Convert(varchar, (@WaivedCharges) )
				EXEC WireIncidents_Create	@Control,'SYSTEM',@WireDATETIME,@WireIncidentType,@Message,1,0,0,@PO_IncidentRETURN OUTPUT,@PO_IncidentMsgError OUTPUT
			    EXEC Inc_AutomaticWireIncident_Create @Control ,'REPLACEMENT_WIRE_CREATE' ,0 ,@Message ,'SYSTEM'
			END
			IF NOT EXISTS (SELECT control FROM ReqCancellation
			                Where control = @ReplacedControl
							  AND ReqStatus <> 'C')
				BEGIN
				  DECLARE @error int
				  EXEC ReqCancellation_Create @ReplacedControl	,32,1,@CreatedBy,1,0,@Error OUTPUT
				END


			DECLARE @OldName varchar(150)
			
			Select @OldName = Receivername 
			from Wires
			Where Control = @ReplacedControl
			
			set @Message = 'Esperando Confirmacion del pagador para cancelar el Giro y proceda el Giro de reemplazo, Nombre del Beneficiario cambio de '+RTRIM(@OldName)+' A '+rtrim(@ReceiverName)
			
			EXEC Inc_AutomaticWireIncident_Create @ReplacedControl ,'REPLACEMENT_ORI_WIRE' ,32 ,@Message ,'SYSTEM'
            
            IF @WireReplacementType = 2
              BEGIN
                IF EXISTS(Select 1 FROM Wires
                           Where Control = @ReplacedControl
                             and StsCancel = 2)
                   EXEC Wires_ReleaseReplacementWire @Control,0
              END
        
        END               

		IF @NoFaxBackWire = 1
		   BEGIN
		     INSERT INTO WiresNoFaxBack with(rowlock)
					   (Control		   ,AgSenderCode	   ,AgSenderSeq
					   ,FaxSent  	   ,FaxStatus		   ,Created
					   ,Processed)
				 VALUES
					   (@Control,	    @AgSenderCode,	    @AgSenderSeq, 
					    null,  	        0,   			    GETDATE(),
					    0 )
		   END
		   
		IF @CustMessage <> ''
		BEGIN
			INSERT INTO WireMessages with(rowlock) (Control, Message) VALUES (@Control, @CustMessage)
		END

		IF (@StsComplianceOk = 0) OR (@CompReleaseDate IS NOT NULL) 
	  	     BEGIN
			   --EXECUTE Wires_CompWireOnHold_Bridge	@WireId,      @Control ,
			   --                                       @WirePurpose, @FundSource, 
		       --                                       @Occupation,  @SndRcvRelationShip,
		       --                                       @SndDOB      ,@SenderGroupId    
		         SELECT
		             @WirePurpose        = ISNULL(rtrim(@WirePurpose),''),
				     @FundSource         = ISNULL(rtrim(@FundSource),''),
				     @Occupation         = ISNULL(rtrim(@Occupation),''),
				     @SndRcvRelationShip = ISNULL(rtrim(@SndRcvRelationShip),''),
				     @SndEmployerName    = ISNULL(rtrim(@SndEmployerName),''),
				     @SndEmployerPhone   = ISNULL(rtrim(@SndEmployerPhone),''),
					 @SenderIdRecId      = ISNULL(@SenderIdRecId, 0)
			      
				  IF @WirePurpose <> '' OR @FundSource <> '' OR @Occupation <> '' OR @SndRcvRelationShip <> '' OR
				     @SndEmployerName <> '' OR @SndEmployerPhone <> '' OR @SenderIdRecId > 0
                    BEGIN
					  INSERT INTO WireCompInfo with(rowlock)
  							   (Control, WirePurpose, FundSource, Occupation, SndRcvRelationShip, SndDOB, 
								SndEmployerName, SndEmployerPhone, SenderIdRecId, RcvDOB, SndCitizenShip)
						VALUES (@Control, @WirePurpose, @FundSource, @Occupation, @SndRcvRelationShip, @SndDOB, 
								@SndEmployerName, @SndEmployerPhone, @SenderIdRecId, @RcvDOB, @Citizenship)

					  IF @Occupation <> ''
						 BEGIN
						   UPDATE Comp_SndGroups WITH(UPDLOCK) 
					 		  SET Occupation    = @Occupation
							WHERE SenderGroupId = @SenderGroupId
						 END
                    END
				
				
				IF @SndDOB<> ''
					 BEGIN
						  UPDATE Comp_SndGroups WITH(UPDLOCK)
						  SET DOB = COALESCE(DOB, @SndDOB)
						  WHERE SenderGroupId = @SenderGroupId
				     END
		     
		  END	
		     
	    	     --NUEVOS INCIDENTES X GERU	
		 IF (@StsComplianceOk = 0) --Retenido por compliance
		    BEGIN
			  SET @Message = 'Giro pendiente por cumplimiento'
			  EXEC Inc_AutomaticWireIncident_Create @Control ,'ONHOLDBYCOMPLIANCE' ,0 ,@Message ,'SYSTEM' 
			END    


			--=====================NOVIEMBRE 14 2018============================

				--NUEVOS INCIDENTES X JOSE	
		IF (@StsCreditOk = 0) --Retenido por credito
			BEGIN
				SET @Message = 'Giro pendiente por credito'
				EXEC Inc_AutomaticWireIncident_Create @Control ,'ONHOLDBYCREDIT' ,0 ,@Message ,'SYSTEM' 
			END

		--NUEVOS INCIDENTES X JOSE	
		IF (@StsFraudCheckOK = 0) --Retenido por cybersource
			BEGIN
				SET @Message = 'Giro pendiente por cybersource'
				EXEC Inc_AutomaticWireIncident_Create @Control ,'ONHOLDBYCYBERSOURCE' ,0 ,@Message ,'SYSTEM' 
			END

		--NUEVOS INCIDENTES X JOSE	
		IF (@StsUserKBAOk = 0) --Retenido por KBA
			BEGIN
				SET @Message = 'Giro pendiente por KBA'
				EXEC Inc_AutomaticWireIncident_Create @Control ,'ONHOLDBYKBA' ,0 ,@Message ,'SYSTEM' 
			END



			--====================================================================






  --Update Comp_SndGroups

		--Comisiones --Grabarlo Siempre no importa si la agencia toma comissiones diarias o mensuales!!!!
		INSERT INTO WireSndComiMonthlyPaid with(rowlock) (Control, SndComissionMonthlyPaid)
		VALUES (@Control, 0)		
		

		IF @ExclStatement > 0
			SET @WireAgSndStatementStatus = 'P'
		ELSE
			SET @WireAgSndStatementStatus = 'R'


        -- multimoneda...
		

		INSERT INTO WireAgSndStatement with(rowlock)
				    (AgencyId           ,AgencyCode                ,Control
				    ,StatementId        ,Status                    ,AccAmount
				    ,OriToAccExRate     ,AccToDestExRate           ,AccDate
					,AccAgPayerCommission)
		     VALUES (@AgSenderId       , @AgSenderCode             ,@Control 
		             ,0                , @WireAgSndStatementStatus ,@AccAmount
		             ,@OriToAccExRate  , @AccToDestExRate          ,@WireDate
					 ,@AccAgPayerCommission)
		             
		--INSERT INTO WireAgSndStatement with(rowlock)
		--		    (AgencyId           ,AgencyCode                ,Control
		--		    ,StatementId        ,Status                    ,AccAmount
		--		    ,OriToAccExRate     ,AccToDestExRate           ,AccDate)

		--     VALUES (@AgSenderId       , @AgSenderCode             ,@Control 
		--             ,0                , @WireAgSndStatementStatus ,@OriAmount
		--             ,1.00             , @OriToDestExRate          ,@WireDate)
		

		INSERT INTO WireAgPayerStatement with(rowlock)
		            (AgencyId,   AgencyCode,   Control, PayerStatementId)
		     VALUES (@AgPayerId, @AgPayerCode, @Control, 0)


		--Insert Record in WireSndBnfCorr for control duplicity	
			
		INSERT INTO WireSndBnfCorr with(rowlock)
				   (Control,	
				    Sender,		
				    Receiver,	
				    BothNames,
				    WireDate,	
				    Show)
		     VALUES(@Control,	
		            @SenderName,
				    @ReceiverName,
				    @SenderName + @ReceiverName,
				    @WireDATETIME,
				    1)

    --=======================CARD DIRECT =====================================
	IF @SenderPaymentMethodId = 5 
	   BEGIN
	     DECLARE @SPMTransactionId int
		 DECLARE @ResultErrorCode VARCHAR(10)
	     EXEC WiresSPM_Transactions_Create @Control            ,@AgSenderId             ,@AgSenderCode 
                                          ,@AgSenderSeq        ,@SenderPaymentMethodId  ,'PAYMENT'
                                          ,@TransacTotalAmount ,@OriAmount              ,@Charges 
										  ,@AgDailyCommission  ,@AgSenderCommission     ,@WireSenderPaymentMethodFee 
										  ,@WireStateFee       ,@CashBackAmount         ,@LegalEntityCode
										  ,@CardTypeCode       ,@LastFourOfCard         ,@NameOnTheCard 
										  ,@PnRef              ,@AuthCode               ,@TransactionErrorCode  
										  ,@TransactionErrorMessage ,@CardDirectProviderId,
										   @ResultErrorCode OUTPUT,@SPMTransactionId  OUTPUT
										  
		UPDATE Wires with(rowlock) 
		    SET SndPaymentMethodTransacId = @SPMTransactionId 
		Where Control = @Control
	   END

    --===================CRM===========================CRM=======================================

	  --Si tiene promocion Inserto la tabla CRM_PromotionControl
	  IF @CRMPromotionId IS NOT NULL
     AND @CRMPromotionId <> 0
	     BEGIN
		    SELECT @PromoCode = PromoCode
			  FROM SqlDataEntry.WirePricing.dbo.CRM_Promotions with(nolock)
			  WHERE PromotionId = @CRMPromotionId

		    IF @PromoUniqueKey IS NULL
			OR @PromoUniqueKey = ''
			   BEGIN
			      SET @PromoUniqueKey= @PromoCode 
			   END

			SELECT @SameSenderId = SameSenderId
			  FROM Senders
			 WHERE SenderId = @SenderId

			INSERT INTO CRM_PromotionControl with(rowlock)
					   (Control
					   ,PromotionId
					   ,SenderPromoUniqueKey
					   ,ReferredBy
					   ,SameSenderId
					  )
				 VALUES
					   (@Control
					   ,@CRMPromotionId
					   ,@PromoUniqueKey
					   ,''
					   ,@SameSenderId)
            --Si hubo descuento Inserto una transaccion de Promocion en la tabla Acc_transactions
         
             IF (@StsCancel = 0) --No ingresar movimientos contables para giros void
			AND (@DiscountAmount > 0)
			AND (((@PromoCostoToCompany IS NOT NULL)  and (@PromoCostoToCompany > 0))
			       OR  ((@PromoCostToPayer IS NOT NULL) AND (@PromoCostToPayer > 0)))

		       BEGIN
			     IF @WirePointsSign = -1
                AND @WirePoints <> 0
				     SET @CRMPromoTranTypeId = dbo.GetNumParam('LoyaltyRedeemTranType')
				ELSE SET @CRMPromoTranTypeId = dbo.GetNumParam('CRM_PromotionTranType')
				  
				  			
                  SELECT @CRMPromoSign  = AccTranSign 
				    FROM Acc_TranTypes 
				   WHERE AccTranTypeID = @CRMPromoTranTypeId

			  
				  DECLARE @CRMPromoTransactionId int 
				  DECLARE @TranAmount MONEY
				  SET @TranAmount = ISNULL(@PromoCostoToCompany,0)+ISNULL(@PromoCostToPayer,0)

				  INSERT INTO Acc_Transactions with(rowlock) 
						   (AgencyId, AgencyCode, AccTranAgencyType, AccTranDate  
						   ,AccTranTypeID, Amount, CurrencyCode, AccSign, Control  
						   ,Reference, CompanyBankAccountId, BankTranTypeId  
						   ,BankReference, AccTranMsg, EnterDate, AccTranStatus  
						   ,PayerCurrencyCode, PayerLCAmount, AccTranEnterBy  
						   ,ImportFileId, ApplyToInTransit, ToBeInclInStatement  
						   ,StatementId, InTransitStatus, InTransitBalance, ScanDate)  
					 VALUES  
						   (@AgSenderId, @AgSenderCode, 'S', @WireDate  
						   ,@CRMPromoTranTypeId, @TranAmount, @OriCurrency, @CRMPromoSign, @Control  
						   ,@AgSenderSeq, 0, 0, 
						   '', @PromoCode, @WireDAtetime, 'A'  
						   ,'', 0, 'SYSTEM'  
						   ,0, 0, 1  
						   ,0  , '', 0, null)
						   
				  SET @CRMPromoTransactionId = SCOPE_IDENTITY()
				  
				  UPDATE CRM_PromotionControl with(updlock)
				     set CRMPromoTransactionid= @CRMPromoTransactionId
				   WHERE Control = @Control

				  
			   END

            --Si el giro dedimio puntos , actualizo el control en el registro de aplicacion de puntos
			IF EXISTS( SELECT *  FROM CRM_SameSenderPointsDetailApplied
			                    WHERE AgSenderCode = @AgSenderCode  
			                      AND AgSenderSeq  = @AgSenderSeq)
			   BEGIN
			     UPDATE CRM_SameSenderPointsDetailApplied SET Control =@Control
				  WHERE AgSenderCode = @AgSenderCode  
			        AND AgSenderSeq  = @AgSenderSeq
			   END

		 END


    --Update Control en CRM_WiresAlreadyCountInPromo
      IF @WiresAlreadyCountGUID IS NOT NULL
	     BEGIN
		   UPDATE CRM_WiresAlreadyCountInPromo with(updlock)
		      SET ControlPromoApplied = @Control
			WHERE WiresAlreadyCountGUID = @WiresAlreadyCountGUID
		 END

    --==============================END CRM

      --Sync table of searching server To Sync Last Wire Sender Receiver
      INSERT INTO SyncDataSrc with(rowlock) (TableName, TableID)
      VALUES('WIRES', @Control)

 if @TranTypeID = 3 --Deposit 
    exec spu_ReceiverBankAccounts @ReceiverID, @AccountNumber, @AccountType, @BankBranchCode, @RcvCountry, @DeptBankName, @AgPayerCode,
	     @AgPayerRcvIdTypeRecordId ,@RcvIdNumber 
 


COMMIT TRAN  --=================COMMIT

 IF @WirePointsSign = -1 --Si Redimio puntos
AND @WirePoints <> 0
    BEGIN
	  UPDATE SqlDataEntry.PaymentDataEntry.dbo.CRM_WirePointsRedeemptionToProcess  SET Control = @Control
	   WHERE Processed is null
	     AND AgSenderCode = @AgSenderCode
	     AND AgSenderSeq = @AgSenderSeq
	END

   --IF @WebAgencyRunOutCredit = 1
   --  EXEC SendEmailAgencyRunOutOfCredit @AgSenderCode

     --Si la agencia es Cash Direct y el giro quedo retenido x cumplimiento, genero una Alerta --Geru Apr 2018
    IF @AgCashDirect = 1
   AND @StsComplianceOk = 0
   AND @StsCancel = 0
       EXEC SqlDataEntry.WireSearch.dbo.CashDirect_Alerts_Insert @AgSenderCode,'H',@Control 
		
   IF @FXDif <> 0
	   SET @FxDifAmount = ((@FXDif*-1) * @OriAmount) / (@OriToDestExRate + (@FXDif*-1))
   ELSE 
	   SET @FxDifAmount = 0

    IF NOT EXISTS(select * from sqlDataEntry.WirePricing.dbo.Prc_WirePlans with(nolock) where Control = @Control)
       BEGIN
		INSERT INTO sqlDataEntry.WirePricing.dbo.Prc_WirePlans with(rowlock)
				   (Control, FeePlanID, ExRatePlanID, AgCommiPlanID, FxShareId
				   ,FXDif, FxDifAmount, FxDifCurrencyCode, WireDate
				   ,AgencyPricingId          ,AgencyPricingDetailId  ,FxBaseId            ,FXPromotionId  
                   ,FxBase                   ,AgencyFXPointsFromBase ,AgencyPromoFXPoints,
				    FXBasePromotionId, FxBasePromotion)
			 VALUES
				   (@Control, @FeePlanID, @FxPlanID, @AgCommiPlanID, @FxShare_Id
				   ,@FXDif, @FxDifAmount, @OriCurrency, @WireDate
				   ,@AgencyPricingId          ,@AgencyPricingDetailId  ,@FxBaseId                  ,@FXPromotionId 
                   ,@FxBase                   ,@AgencyFXPointsFromBase ,@AgencyPromoFXPoints
				   ,@FXBasePromotionId , @FxBasePromotion)
        END
    
 if @AssignLoyaltyCard = 1  --This is done only for new senders
    begin 
      EXEC CRM_Load_SameSender_Loyalty @SenderId
      
      Set @SameSenderId = null
      
      SELECT @SameSenderId = SameSenderId 
      FROM Senders
	  WHERE SenderId = @SenderId

      if (@LoyaltyCardNumber IS NOT NULL AND rtrim(@LoyaltyCardNumber) <> '')
	    and not exists (Select * from CRM_SenderLoyaltyCards where CardNumber = @LoyaltyCardNumber)
	    begin
		  IF @SameSenderId = 0
		  OR @SameSenderId iS NULL
		     BEGIN
			    EXEC CRM_SameSenders_Create 0, null,  0, '', 0, @SenderId;
				SELECT @SameSenderId = SameSenderId FROM Senders Where SenderId = @SenderId
			 END

	      insert into CRM_SenderLoyaltyCards with(rowlock) (SenderId, SameSenderId, CardNumber, ActivatedBy) values(@SenderId, @SameSenderId, @LoyaltyCardNumber, @AgSenderCode)  
	       -- update LoyaltyCardNumber in CRM_SameSenders
		  update CRM_SameSenders
		     set LoyaltyCardnumber = @LoyaltyCardNumber
		   where samesenderid = @SameSenderId
		end

    end	  
  
     
		
   UPDATE AgSenderAccounting with(updlock) 
      SET AgLastWireDate = GetDate()
    WHERE AgencyID = @AgSenderID

    exec CheckWireForRTC_HighAmountUnusualActivity @Control, @WireTotalAmount, @AgSenderCode
---	SET @pO_ERROR_MSG = ''

   
     --Si es WebAgent Se verifica que el estado seleccionado por el usuario coincida con el detectado por MaxMaind
   --Si no se retiene x compliance para verificacion
  -- IF @WebAgent = 1
  --    BEGIN
	 --    IF @IPDetectedState IS NOT NULL
		--AND RTRIM(ltrim(@IPDetectedState)) <> ''
		--AND rtrim(ltrim(@IPDetectedState)) <> rtrim(ltrim(@WireFromState))
		--    BEGIN
		--	  DECLARE @MsgHold varchar(300)
		--	  SET @MsgHold = 'Please,Call Sender to Verify GeoLocation - State Detected: '+@IPDetectedState
		--	  EXEC dbo.Comp_WireOnHold_ManualWireOnHold @Control,'SYSTEM',0,108,@MsgHold
		--	END

	 -- END

    IF @WireTotalAmount > 1000
   and @WebAgent = 0
   and rtrim(@RcvZip) <> ''
   and rtrim(@RcvZip) <> 'NA'
   and rtrim(@RcvZip) <> '000'
   and rtrim(@RcvZip) <> '0000'
   and rtrim(@RcvZip) <> '00000'
   and rtrim(@RcvZip) <> '000000'
   and rtrim(@RcvZip) <> '0'
   and rtrim(@RcvZip) <> '00'
   and @DestCountry = 'MEXICO'
       BEGIN
         EXEC dbo.Comp_WireOnHold_ManualWireOnHold @Control,'SYSTEM',0,41,'Please,Call Agent to verify (Case 2)'
       END

 -- IF (@WireTotalAmount > 1000)  --Se quita a pedido de Compliance el 22 de octubre de 2015 (Jose, Jesus y Loreto)
 --AND (@DestCountry = 'MEXICO') 
 --AND (@TranTypeID = 1)
 --AND (@SourceApp <> 2)
 --AND (@NewSnd = 0)  --Agregue que el remitente tiene historial
 --    BEGIN
 --        IF EXISTS (SELECT 1 FROM ReceiverVersions
 --                    WHERE ReceiverId   = @ReceiverId
 --                      AND RcvVersionId = @RcvLastVersionID
 --                      AND dbo.dateonly(VersionDate) = @WireDate)
 --           BEGIN
	--		  IF @RcvLastVersionID = 1
	--		     BEGIN
 --                  EXEC dbo.Comp_WireOnHold_ManualWireOnHold @Control,'SYSTEM',0,41,'Please,Call Agent to verify (Case 3)'
	--		     END
	--		  ELSE BEGIN
	--		         IF @RcvLastVersionID > 1
	--				    BEGIN
	--						 IF EXISTS (SELECT * FROM ReceiverVersions
	--									 WHERE Receiverid = @ReceiverId
	--									   AND RcvVersionId = @RcvLastVersionID - 1
	--									   AND rtrim(RcvFirstName) + rtrim(RcvLast1) + rtrim(RcvLast2 ) <> rtrim(@RcvFirstName)+rtrim(@RcvLast1)+rtrim(@RcvLast2))
	--							BEGIN
	--							  EXEC dbo.Comp_WireOnHold_ManualWireOnHold @Control,'SYSTEM',0,41,'Please,Call Agent to verify (Case 3)'
	--							END
	--					END
	--		       END

 --           END
 --    END
     
   IF (@PossibleFraud  = 1)
       BEGIN
         EXEC dbo.Comp_WireOnHold_ManualWireOnHold @Control,'SYSTEM',0,41,'Please,Call Agent to verify (Case 4)'
       END

  --IRS REQUEST
		IF EXISTS (Select * FROM SqlDataEntry.WireCompliance.dbo.Comp_WiresOnIRSHold Where WireId = @WireId)
		  begin
		    DECLARE @BrName varchar(40)
			DECLARE @HoldType char(1)
			DECLARE @CompGuidid uniqueidentifier

			SELECT @BrName = BrName
			  FROM Branches WHERE BranchId = @BranchId
			
			Select @CompGuidid = GuidId,
			       @HoldType = HoldType
			  FROM SqlDataEntry.WireCompliance.dbo.Comp_WiresOnIRSHold 
			  Where WireId = @WireId 

            IF (@HoldType = 'L')
		    OR (@HoldType = 'B' and @BrName in ('157','523','1486','2451','2733','6591'))
			   BEGIN
					UPDATE SqlDataEntry.WireCompliance.dbo.Comp_WiresOnIRSHold 
					   Set Control = @Control
					 WHERE WireId = @WireId

					EXEC dbo.Comp_WireOnHold_ManualWireOnHold @Control,'SYSTEM',0,67,'Para preguntas comunicarse con el Departamento de Cumplimiento en Miami'  --Compliance Assistance
									
					set @Message = 'Si el REMITENTE o BENEFICIARIO pregunta por este giro, instruir que puede obtener mayor información llamando al 1-800-659-9173'
				--	EXEC WireIncidents_Create @Control,'SYSTEM',@WireDATETIME,3,@Message,1,0,0,@PO_IncidentRETURN OUTPUT,@PO_IncidentMsgError OUTPUT
					EXEC Inc_AutomaticWireIncident_Create @Control ,'IRS_HOLD' ,0 ,@Message ,'SYSTEM' 
		       END
			ELSE BEGIN
			      -- insert into debug (agencyid,s,d,t) values (@Control,@CompGuidid,getdate(),null)
				   EXEC Comp_RunComplianceFilters @Control,@WireId,@CompGuidid
			     END
		  end
	--END IRS REQUEST


	IF @WebAgent = 1 --Web Agent Wires
	   BEGIN 
	     UPDATE SqlDataEntry.PaymentDataEntry.dbo.WebAgent_WireGeolocationInfo set Control = @Control
		  WHERE TransactionId = @WebAgentTransationId
	   END

   --AGENCY HOURS OF OPERATION VALIDATION

   --BEGIN TRY
   --     EXEC CHECK_AGENT_OPER_TIME  @AgSenderCode,@WireDateTime ,  @ValidOK  OUTPUT
   --END TRY
   --BEGIN CATCH
   --  SET @ValidOK = 0
   --END CATCH
   --IF @ValidOK = 0
   --  BEGIN
   --      EXEC dbo.Comp_WireOnHold_ManualWireOnHold @Control,'SYSTEM',0,41,'Wire made before or after Agency Hours of Operation, Please Call Agent to verify'
   --  END

END TRY
BEGIN CATCH

    IF @@TRANCOUNT <> 0
    BEGIN
		ROLLBACK TRAN
    END

	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = 'Wires_InsertWireTranfer_Bridge_CENPOS - ' + Cast(@Step as varchar) + ' - ' + ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    -- Use RAISERROR inside the CATCH block to return error
    -- information about the original error that caused
    -- execution to jump to the CATCH block.
    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH

END