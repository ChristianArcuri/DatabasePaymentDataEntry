CREATE PROCEDURE [dbo].[Wires_Bridge_Geru]
AS
BEGIN
DECLARE @WireId int  ,
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
	@SenderName varchar(100) ,
	@OnBehalfName varchar(100) ,
	@ReceiverName varchar(100) ,
	@PinNumber varchar(20) ,
	@WireDate datetime ,
	@WireDatetime datetime ,
	@OriAmount money ,
	@OriCurrency char(3) ,
	@Charges money ,
	@OtherChg money ,
	@AgencyFee money ,
	@OriToDestExRate money ,
	@WireStateFee money ,
	@WireTotalAmount money ,
	@DestAmount money ,
	@DestCurrency char(3) ,
	@AgSenderCommission money ,
	@TranTypeID int ,
	@AccountNumber varchar(20) ,
	@DeptBankName varchar(60) ,
	@AccountType smallint ,
	@DeptAdditionalInfo varchar(60) ,
	@BankBranchCode varchar(7) ,
	@DeliveryType char(1) ,
	@SourceApp int ,
	@StsComplianceOk bit ,
	@StsCancel smallint ,
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
	@NewTelewire bit ,
	@FxPointsAdded money ,
	@FXChangeCost money ,
	@FXCostApplyTo char(1) ,
	
	@SenderGroupId  int,
	@SndFirstName  varchar(50),
	@SndLast1  varchar(50),
	@SndLast2  varchar(50),
	@SndAddress  varchar(50),
	@SndCountry  varchar(30),
	@SndState  varchar(30),
	@SndCity  varchar(40),
	@SndZip  varchar(15),
	@SndPhone  varchar(20),
	@SndLastVersionId  int,
	@SndNoSecLastName  bit,
	
	--Receiver Information
	@ReceiverGroupId  int,
	@RcvFirstName  varchar(50),
	@RcvLast1  varchar(50),
	@RcvLast2  varchar(50),
	@RcvAddress  varchar(200),
	@RcvCountry varchar(30) ,
	@RcvState  varchar(30),
	@RcvCity  varchar(40),
	@RcvZip  varchar(15),
	@RcvPhone   varchar(20),
	@RcvNoSecLastName  bit,
	@RcvLastVersionID  int,
	@CPF  varchar(11)
	
DECLARE @CompReleaseDate datetime
DECLARE @CompReleaseBy varchar(15)
DECLARE @Control INT
DECLARE @pO_ERROR_MSG VARCHAR(255)
DECLARE @ExclStatement BIT
DECLARE @FxDifAmount MONEY

SET @pO_ERROR_MSG = ''


BEGIN TRY
   DECLARE c_cursor cursor for
    SELECT W.WireId
		  ,W.LSenderId
		  ,W.LReceiverId
		  ,W.AgSenderId
		  ,W.AgSenderCode
		  ,W.AgSenderSeq
		  ,W.AgSenderState
		  ,W.AgSenderCity
		  ,W.AgSenderCountry
		  ,W.AgPayerId
		  ,W.AgPayerCode
		  ,W.DestCountry
		  ,W.DestState
		  ,W.DestCity
		  ,W.BranchId
		  ,W.SenderId
		  ,W.OnBehalfId
		  ,W.ReceiverId
		  ,W.SenderName
		  ,W.OnBehalfName
		  ,W.ReceiverName
		  ,W.PinNumber
		  ,W.WireDate
		  ,W.WireDatetime
		  ,W.OriAmount
		  ,W.OriCurrency
		  ,W.Charges
		  ,W.OtherChg
		  ,W.AgencyFee
		  ,W.OriToDestExRate
		  ,W.WireStateFee
		  ,W.WireTotalAmount
		  ,W.DestAmount
		  ,W.DestCurrency
		  ,W.AgSenderCommission
		  ,W.TranTypeID
		  ,W.AccountNumber
		  ,W.DeptBankName
		  ,W.AccountType
		  ,W.DeptAdditionalInfo
		  ,W.BankBranchCode
		  ,W.DeliveryType
		  ,W.SourceApp
		  ,W.StsComplianceOk
		  ,W.StsCancel
		  ,W.CustTrasactionID
		  ,W.RateTypeID
		  ,W.FeePlanID
		  ,W.FxPlanID
		  ,W.AgCommiPlanID
		  ,W.FXDif
		  ,W.FXShare_id
		  ,W.ExRateMacro
		  ,W.WirePurpose
		  ,W.FundSource
		  ,W.Occupation
		  ,W.IncomingPhoneNumber
		  ,W.CallerIDVerif
		  ,W.TeledirectWire
		  ,W.NoFaxBackWire
		  ,W.ReplacedControl
		  ,W.WaivedCharges
		  ,W.ReplaceWireRcvSel
		  ,W.CustMessage
		  ,W.WireReplacementType
		  ,W.ReplacementReasonID
		  ,W.MemberCardSwiped
		  ,W.SndDOB
		  ,W.CreatedBy
		  ,W.ComputerName
		  ,W.PayerPayMethodId
		  ,W.SndRcvRelationship
		  ,W.NewTelewire
		  ,W.FxPointsAdded
		  ,W.FXChangeCost
		  ,W.FXCostApplyTo
		  
		  ,S.SenderGroupId  
		  ,S.SndFirstName  
		  ,S.SndLast1  
		  ,S.SndLast2  
		  ,S.SndAddress  
		  ,S.SndCountry  
		  ,S.SndState 
		  ,S.SndCity  
		  ,S.SndZip  
		  ,S.SndPhone  
		  ,S.SndLastVersionId  
		  ,S.SndNoSecLastName  
		  
		  ,R.ReceiverGroupId  
		  ,R.RcvFirstName  
		  ,R.RcvLast1  
		  ,R.RcvLast2  
		  ,R.RcvAddress  
		  ,R.RcvCountry  
		  ,R.RcvState  
		  ,R.RcvCity  
		  ,R.RcvZip  
		  ,R.RcvPhone  
		  ,R.RcvNoSecLastName  
		  ,R.RcvLastVersionID  
		  ,R.CPF  
      FROM Wires as W
           INNER JOIN ProcessedWires_ as P on (W.WireId = P.WireId)
           INNER JOIN Senders as S        on (W.LSenderId = S.LSenderId)
           INNER JOIN Receivers as R      on (W.LReceiverId = R.LReceiverId)
       WHERE Done =0


	OPEN c_cursor
	FETCH c_cursor INTO @WireId   ,
						@LSenderId  ,
						@LReceiverId  ,
						@AgSenderId  ,
						@AgSenderCode  ,
						@AgSenderSeq  ,
						@AgSenderState  ,
						@AgSenderCity  ,
						@AgSenderCountry  ,
						@AgPayerId  ,
						@AgPayerCode  ,
						@DestCountry  ,
						@DestState  ,
						@DestCity  ,
						@BranchId  ,
						@SenderId  ,
						@OnBehalfId  ,
						@ReceiverId  ,
						@SenderName  ,
						@OnBehalfName  ,
						@ReceiverName  ,
						@PinNumber ,
						@WireDate  ,
						@WireDatetime  ,
						@OriAmount  ,
						@OriCurrency  ,
						@Charges  ,
						@OtherChg  ,
						@AgencyFee  ,
						@OriToDestExRate  ,
						@WireStateFee  ,
						@WireTotalAmount  ,
						@DestAmount  ,
						@DestCurrency  ,
						@AgSenderCommission  ,
						@TranTypeID  ,
						@AccountNumber  ,
						@DeptBankName  ,
						@AccountType  ,
						@DeptAdditionalInfo  ,
						@BankBranchCode  ,
						@DeliveryType  ,
						@SourceApp  ,
						@StsComplianceOk  ,
						@StsCancel  ,
						@CustTrasactionID  ,
						@RateTypeID  ,
						@FeePlanID  ,
						@FxPlanID  ,
						@AgCommiPlanID  ,
						@FXDif  ,
						@FXShare_id  ,
						@ExRateMacro  ,
						@WirePurpose  ,
						@FundSource  ,
						@Occupation  ,
						@IncomingPhoneNumber  ,
						@CallerIDVerif  ,
						@TeledirectWire  ,
						@NoFaxBackWire  ,
						@ReplacedControl  ,
						@WaivedCharges  ,
						@ReplaceWireRcvSel  ,
						@CustMessage ,
						@WireReplacementType  ,
						@ReplacementReasonID  ,
						@MemberCardSwiped  ,
						@SndDOB  ,
						@CreatedBy  ,
						@ComputerName  ,
						@PayerPayMethodId  ,
						@SndRcvRelationship  ,
						@NewTelewire  ,
						@FxPointsAdded  ,
						@FXChangeCost  ,
						@FXCostApplyTo  ,
						
						@SenderGroupId  ,
						@SndFirstName  ,
						@SndLast1  ,
						@SndLast2  ,
						@SndAddress  ,
						@SndCountry  ,
						@SndState  ,
						@SndCity  ,
						@SndZip  ,
						@SndPhone  ,
						@SndLastVersionId  ,
						@SndNoSecLastName  ,
						
						--Receiver Information
						@ReceiverGroupId  ,
						@RcvFirstName  ,
						@RcvLast1  ,
						@RcvLast2  ,
						@RcvAddress  ,
						@RcvCountry  ,
						@RcvState  ,
						@RcvCity  ,
						@RcvZip  ,
						@RcvPhone   ,
						@RcvNoSecLastName  ,
						@RcvLastVersionID  ,
						@CPF  
						
	WHILE (@@Fetch_Status = 0)
		BEGIN
		
		   SET @ExclStatement = 0
		   IF @StsComplianceOk = 0 --The wire is on hold by compliance
		        BEGIN
		           SET @CompReleaseDate = NULL
		           SET @CompReleaseBy    = ''
		           IF  NOT EXISTS (Select * 
		                             from WireCompliance.dbo.Comp_WireOnHold as h
		                                  inner join WireCompliance.dbo.Comp_OnHoldReasons as R on (h.OnHoldReasonId = R.OnHoldReasonId)      
		                            where h.WireId = @WireId
		                              and h.Status ='P'
		                              and R.ExclStatement = 0)
 	                   SET @ExclStatement = 1
		        END
		   ELSE BEGIN
		           IF EXISTS(Select * from WireCompliance.dbo.Comp_WireOnHold
		                      where WireId = @WireId
		                        and Status ='A')
		                BEGIN 
		                  SET @CompReleaseDate = getdate()
		                  SET @CompReleaseBy    = 'SYSTEM'
		                END
		           ELSE BEGIN
		                  SET @CompReleaseDate = NULL
		                  SET @CompReleaseBy    = ''

		                END
		   
		        END
		   
	  
        --   EXEC [10.128.252.141].WireTransac.dbo.Wires_InsertWireTranfer_Bridge	
           EXEC [sqlmain].WireTransac.dbo.Wires_InsertWireTranfer_Bridge	
                                @WireId  ,
								@LSenderId  ,
								@LReceiverId  ,
								@AgSenderId  ,
								@AgSenderCode ,
								@AgSenderSeq  ,
								@AgSenderState  ,
								@AgSenderCity  ,
								@AgSenderCountry  ,
								@AgPayerId  ,
								@AgPayerCode  ,
								@DestCountry  ,
								@DestState  ,
								@DestCity  ,
								@BranchId  ,
								@SenderId  ,
								@OnBehalfId  ,
								@ReceiverId  ,
								@SenderName  ,
								@OnBehalfName  ,
								@ReceiverName  ,
								@PinNumber  ,
								@WireDate  ,
								@WireDatetime  ,
								@OriAmount  ,
								@OriCurrency  ,
								@Charges  ,
								@OtherChg  ,
								@AgencyFee  ,
								@OriToDestExRate  ,
								@WireStateFee  ,
								@WireTotalAmount  ,
								@DestAmount  ,
								@DestCurrency ,
								@AgSenderCommission  ,
								@FXPointsAdded  ,
								@FXChangeCost  ,
								@FXCostApplyTo  ,
								@TranTypeID  ,
								@AccountNumber  ,
								@DeptBankName  ,
								@AccountType  ,
								@DeptAdditionalInfo  ,
								@BankBranchCode  ,
								@DeliveryType ,
								@SourceApp  ,
								@StsComplianceOk  ,
								@CustTrasactionID  ,
								@RateTypeID  ,
								@FeePlanID  ,
								@FxPlanID  ,
								@AgCommiPlanID  ,
								@FXDif  ,
								@FXShare_id  ,
								@ExRateMacro  ,
								@WirePurpose  ,
								@FundSource  ,
								@Occupation  ,
								@IncomingPhoneNumber  ,
								@CallerIDVerif  ,
								@TeledirectWire  ,
								@NoFaxBackWire  ,
								@ReplacedControl  ,
								@WaivedCharges  ,
								@ReplaceWireRcvSel  ,
								@CustMessage  ,
								@WireReplacementType  ,
								@ReplacementReasonID  ,
								@MemberCardSwiped  ,
								@SndDOB  ,
								@CreatedBy  ,
								@ComputerName  ,
								@PayerPayMethodId  ,
								@SndRcvRelationship  ,
								@NewTelewire , 
								@CompReleaseDate ,
								@CompReleaseBy  ,
								@ExclStatement ,

								
								--Sender Information
								@SenderGroupId  ,
								@SndFirstName  ,
								@SndLast1  ,
								@SndLast2  ,
								@SndAddress  ,
								@SndCountry  ,
								@SndState  ,
								@SndCity  ,
								@SndZip  ,
								@SndPhone  ,
								@SndLastVersionId  ,
								@SndNoSecLastName  ,
								
								--Receiver Information
								@ReceiverGroupId  ,
								@RcvFirstName  ,
								@RcvLast1  ,
								@RcvLast2  ,
								@RcvAddress  ,
								@RcvCountry  ,
								@RcvState  ,
								@RcvCity  ,
								@RcvZip  ,
								@RcvPhone  ,
								@RcvNoSecLastName  ,
								@RcvLastVersionID  ,
								@CPF  ,
								@Control  OUTPUT--,
							--	@pO_ERROR_MSG	 OUTPUT

          print 'Control '+convert(varchar,@Control)
          print 'msg '+@pO_ERROR_MSG



           IF (@Control IS NOT NULL)
          AND (@Control <> 0)
          AND (@pO_ERROR_MSG = '')
               BEGIN
				   IF @FXDif <> 0
					   SET @FxDifAmount = ((@FXDif*-1) * @OriAmount) / (@OriToDestExRate + (@FXDif*-1))
  				   ELSE 
					   SET @FxDifAmount = 0
	           
	     --           IF NOT EXISTS(select * from WirePricing.dbo.Prc_WirePlans where Control = @Control)
	     --              BEGIN
						--INSERT INTO WirePricing.dbo.Prc_WirePlans
						--		   (Control
						--		   ,FeePlanID
						--		   ,ExRatePlanID
						--		   ,AgCommiPlanID
						--		   ,FxShareId
						--		   ,FXDif
						--		   ,FxDifAmount
						--		   ,FxDifCurrencyCode
						--		   ,WireDate)
						--	 VALUES
						--		   (@Control
						--		   ,@FeePlanID
						--		   ,@FxPlanID
						--		   ,@AgCommiPlanID
						--		   ,@FxShare_Id
						--		   ,@FXDif
						--		   ,@FxDifAmount
						--		   ,@OriCurrency
						--		   ,@WireDate)
				  --      END
	              
	               
	               
					 UPDATE ProcessedWires_ SET Done = 1,
											   Control = @Control
					  WHERE WireID = @WireId 
                  
               END


		    FETCH c_cursor INTO @WireId   ,
								@LSenderId  ,
								@LReceiverId  ,
								@AgSenderId  ,
								@AgSenderCode  ,
								@AgSenderSeq  ,
								@AgSenderState  ,
								@AgSenderCity  ,
								@AgSenderCountry  ,
								@AgPayerId  ,
								@AgPayerCode  ,
								@DestCountry  ,
								@DestState  ,
								@DestCity  ,
								@BranchId  ,
								@SenderId  ,
								@OnBehalfId  ,
								@ReceiverId  ,
								@SenderName  ,
								@OnBehalfName  ,
								@ReceiverName  ,
								@PinNumber ,
								@WireDate  ,
								@WireDatetime  ,
								@OriAmount  ,
								@OriCurrency  ,
								@Charges  ,
								@OtherChg  ,
								@AgencyFee  ,
								@OriToDestExRate  ,
								@WireStateFee  ,
								@WireTotalAmount  ,
								@DestAmount  ,
								@DestCurrency  ,
								@AgSenderCommission  ,
								@TranTypeID  ,
								@AccountNumber  ,
								@DeptBankName  ,
								@AccountType  ,
								@DeptAdditionalInfo  ,
								@BankBranchCode  ,
								@DeliveryType  ,
								@SourceApp  ,
								@StsComplianceOk  ,
								@StsCancel  ,
								@CustTrasactionID  ,
								@RateTypeID  ,
								@FeePlanID  ,
								@FxPlanID  ,
								@AgCommiPlanID  ,
								@FXDif  ,
								@FXShare_id  ,
								@ExRateMacro  ,
								@WirePurpose  ,
								@FundSource  ,
								@Occupation  ,
								@IncomingPhoneNumber  ,
								@CallerIDVerif  ,
								@TeledirectWire  ,
								@NoFaxBackWire  ,
								@ReplacedControl  ,
								@WaivedCharges  ,
								@ReplaceWireRcvSel  ,
								@CustMessage ,
								@WireReplacementType  ,
								@ReplacementReasonID  ,
								@MemberCardSwiped  ,
								@SndDOB  ,
								@CreatedBy  ,
								@ComputerName  ,
								@PayerPayMethodId  ,
								@SndRcvRelationship  ,
								@NewTelewire  ,
								@FxPointsAdded  ,
								@FXChangeCost  ,
								@FXCostApplyTo  ,
								@SenderGroupId  ,
						@SndFirstName  ,
						@SndLast1  ,
						@SndLast2  ,
						@SndAddress  ,
						@SndCountry  ,
						@SndState  ,
						@SndCity  ,
						@SndZip  ,
						@SndPhone  ,
						@SndLastVersionId  ,
						@SndNoSecLastName  ,
						
						--Receiver Information
						@ReceiverGroupId  ,
						@RcvFirstName  ,
						@RcvLast1  ,
						@RcvLast2  ,
						@RcvAddress  ,
						@RcvCountry  ,
						@RcvState  ,
						@RcvCity  ,
						@RcvZip  ,
						@RcvPhone   ,
						@RcvNoSecLastName  ,
						@RcvLastVersionID  ,
						@CPF  
		END
	CLOSE c_cursor
	DEALLOCATE c_cursor
END TRY
BEGIN CATCH
    CLOSE c_cursor
	DEALLOCATE c_cursor

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = 'Wires_Bridge - '+ERROR_MESSAGE(),
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
