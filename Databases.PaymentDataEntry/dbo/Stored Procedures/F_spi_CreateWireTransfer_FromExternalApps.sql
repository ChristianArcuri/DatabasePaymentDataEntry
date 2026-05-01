CREATE PROCEDURE [dbo].[F_spi_CreateWireTransfer_FromExternalApps]
                 --Agency Sender
                 @AgSender_ID int,
                 @AgSender_No varchar(10),
                 @AgState varchar(30), 
                 @AgCity varchar(30), 

                 --Sender
                 @Sender_ID int,
                 @RAS_Sender_id int,
                 @SndFullName varchar(80),
                 @SndFirstName varchar(35),
                 @SndLast1 varchar(20),
                 @SndLast2 varchar(50),
                 @SndAddress varchar(50),
                 @SndCity varchar(30),
                 @SndState varchar(30),
                 @SndCountry varchar(30),
                 @SndZip varchar(15),
                 @SndPhone varchar(15),
                 --@SndAgencyNo varchar(10),
                 @SenderInfo_ID int,
                 @NewMonthlyLimit money,
                 @SenderIDCount int,
                 @NoSecondLastName bit, 

                 --Receiver
                 @Receiver_ID int,
                 @RAS_Receiver_ID int,
                 @RcvFirstName varchar(30), 
                 @RcvLast1 varchar(50),
                 @RcvLast2 varchar(50),
                 @RcvAddress varchar(200),
                 @RcvCity varchar(30),
                 @RcvState varchar(30),
                 @RcvCountry varchar(30),
                 @RcvZip varchar(15),
                 @RcvPhone varchar(15),

                 --Point of Payment
                 @AgPayer_ID int,
                 @AgPayer_No varchar(10),
                 @Branch_id int,
                 @BrState varchar(30), 
                 @BrCity varchar(30),                

                 --Wire-Transfer
                 @TransfAmount money,
                 @TransfCharges money,
                 @TransfOtherChg money,
                 @TransfAgencyFee money,
                 @TransfTotalAmount money,
                 @ExRateAmount money,
                 @LocalCurrency money,
                 @SndCommission smallmoney,
                 @TransfAccount varchar(20),
                 @DepAdditionalInfo varchar(60),
                 @TransfDeptBank varchar(60),
                 @AccountType smallint,
                 @TranType_ID int,
                 @DeliveryType char(1),
                 @PayCurrency char(1),
                 @TransfSourceApp int,
                 @TransfPINParam varchar(20),

                 --Others
                 @CreatedBy varchar(15),
                 @Message varchar(255),
                 @ReplacedWireControl int,
                 @ReplaceOriChgAmount money,
                 @ReplaceWireRcvSel int,
                 @Cancel bit = 0,              -- Only used for RAS (@TransfSourceApp = 7)
                 @Transfer_ID int = 0,         -- Only used for RAS (@TransfSourceApp = 7)
                 @CustTrasactionID int = 0,    -- Only used for Import (@TransfSourceApp = 8)
                 
                 --No fax back parameters
                 @CallerIDVerified bit = 0,
                 @IncomingCallNum varchar(20) = null,
                 @ExtensionNum varchar(10) = null,

                 --Fee and ExRates
                 @FeePlan_id int,
                 @ExRatePlan_id int,
                 @AgCommiPlan_id int,
                 @ExRateMacro smallint,
                 @FXDif money, ---
                 @FXShare_id int,  ---
                 --
                 @WirePurpose varchar(200),
                 @FundSource varchar(120),
                 @Occupation varchar(80),
                 @No1025_ID_Verified bit,
                 -- 
                 @ComputerName varchar(30),
                 @DestCurrency char(3), 
                 @OriCurrency char(3) 
AS

 return;
 
declare @StsCancel smallint
if (@Cancel = 0)
  set @StsCancel = 0
else if (@TransfAmount = 0)
  set @StsCancel = 1
else 
  set @StsCancel = 2

declare @RcvFullName varchar(25)
select @RcvFullName = rtrim(ltrim(@RcvFirstName)) + ' ' + rtrim(ltrim(@RcvLast1)) + ' ' + rtrim(ltrim(@RcvLast2)),
       @SndFirstName = RTRIM(ltrim(@SndFirstName)), @SndLast1 = RTRIM(ltrim(@SndLast1)), @SndLast2 = RTRIM(ltrim(@SndLast2)),
       @RcvFirstName = RTRIM(ltrim(@RcvFirstName)), @RcvLast1 = RTRIM(ltrim(@RcvLast1)), @RcvLast2 = RTRIM(ltrim(@RcvLast2))

select @Sender_ID = 0, @Receiver_ID = 0, @SenderInfo_ID = 0

exec spi_CreateWire_DataEntry @Sender_ID,
                              @SenderInfo_ID, 
                              @SndFullName, 
                              @SndFirstName, 
                              @SndLast1, 
                              @SndLast2, 
                              @SndAddress, 
                              @SndCountry, 
				              @SndState, 
				              @SndCity, 
				              @SndZip, 
				              @SndPhone, 
				              0, 
				              @NoSecondLastName, 
				              @Receiver_ID, 
				              0, 
				              @RcvFullName, 
				              @RcvFirstName, 
				              @RcvLast1,  
				              @RcvLast2, 
				              @RcvAddress, 
				              @RcvCountry, 
				              @RcvState, 
				              @RcvCity, 
				              @RcvZip, 
				              @RcvPhone, 
				              0, 
				              0, 
				              Null, 
				              @AgSender_ID, 
				              @AgSender_No, 
				              @AgState, 
				              @AgCity, 
				              @SndCountry, 
				              @AgPayer_ID, 
				              @AgPayer_No, 
				              @RcvCountry, 
				              @BrState, 
				              @BrCity, 
				              @Branch_id, 
				              0, 
				              @TransfAmount, 
				              @OriCurrency, 
				              @TransfCharges, 
				              @TransfOtherChg, 
				              @TransfAgencyFee, 
				              @ExRateAmount, 
				              0.0,
				              @TransfTotalAmount, 
				              @LocalCurrency, 
				              @DestCurrency, 
				              @SndCommission, 
				              @TranType_ID, 
				              @TransfPINParam, 
				              @Message, 
				              @TransfAccount, 
				              @TransfDeptBank, 
				              @AccountType, 
				              @DepAdditionalInfo, 
				              '', 
				              @DeliveryType, 
				              @TransfSourceApp, 
				              @StsCancel, 
				              @CustTrasactionID, 
				              0, 
				              @FeePlan_id, 
				              @ExRatePlan_id,  
				              @AgCommiPlan_id, 
				              @FXDif, 
				              @FXShare_id, 
				              @ExRateMacro, 
				              @WirePurpose, 
				              @FundSource, 
				              @Occupation, 
				              @IncomingCallNum, 
				              @CallerIDVerified, 
				              0, 
				              0, 
				              @ReplacedWireControl, 
				              Null, 
				              @ReplaceWireRcvSel, 
				              0, 
				              Null, 
				              0, 
				              Null,
				              @No1025_ID_Verified, 
				              @CreatedBy, 
				              @ComputerName	
				
                  
 
             
