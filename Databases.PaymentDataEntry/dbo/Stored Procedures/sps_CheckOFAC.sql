create   PROCEDURE [dbo].[sps_CheckOFAC]
                 @WireGUID uniqueidentifier,
                 @SenderInfo_id int,
                 @SenderName        varchar(50), -- Transfer Sender Name
                 @SenderFirstName   varchar(80), -----------
                 @SenderLastName    varchar(80), -----------
                 @BeneficiaryName   varchar(50), -- Transfer Receiver Name
                 @ReceiverFirstName varchar(80), ---------
                 @ReceiverLastName  varchar(80), ---------
                 @RcvCountry varchar(30),
--                 @TransfTotalAmount money,       -- Transfer TOTAL Amount
--                 @AgSender_ID       int,
--                 @Branch_ID         int,
                 @Sender_id         int,
                 @Receiver_id       int, 
                 @TransfStsComplianceOk bit output
as
  DECLARE   @Deny_id               int,
            @Ofac_id               int,
            @Msg                   varchar(120),
            @AgState               varchar(30),
            @AuthBy                varchar(15), 
            @AuthDate              datetime, 
            @AuthReason            varchar(128), 
            @OnholdWireStatus      char(1)

  Set @TransfStsComplianceOk = 1

--  insert into dbo.OfacLog (Wire_id,CheckDate,WireGuid) values(0,getdate(),@WireGUID)

-- Search for Sender in OFAC List
  exec WireCompliance.dbo.sps_OFAC_CheckNames @SenderFirstName, @SenderLastName, @RcvCountry, 0, 'S',@SenderInfo_id,@OnholdWireStatus output, @Ofac_id output, @Msg output
  IF @Ofac_id IS NOT NULL 
    begin
      if @OnholdWireStatus = 'P'
        begin
          SET @TransfStsComplianceOk = 0
          Set @AuthBy = null
          Set @AuthDate = null
          Set @AuthReason = null
        end
      else
        begin
          SET @TransfStsComplianceOk = 1
          Set @AuthBy = 'SYSTEM'
          Set @AuthDate = GetDate()
          Set @AuthReason = @Msg
        end
      exec spi_InsWiresComplianceHold @WireGUID ,4,@AuthDate,@AuthBy,@ofac_id,@AuthReason,@Sender_id,@OnholdWireStatus,0
     end

-- Search for Sender in OFAC ALIAS (ALT) List
--/*
  exec WireCompliance.dbo.sps_OFAC_Check_ALT_Names @SenderFirstName, @SenderLastName, @RcvCountry, 'S',@SenderInfo_id,@OnholdWireStatus output, @Ofac_id output, @Msg output
  IF @Ofac_id IS NOT NULL 
    begin
      if @OnholdWireStatus = 'P'
        begin
          SET @TransfStsComplianceOk = 0
          Set @AuthBy = null
          Set @AuthDate = null
          Set @AuthReason = null
        end
      else
        begin
          SET @TransfStsComplianceOk = 1
          Set @AuthBy = 'SYSTEM'
          Set @AuthDate = GetDate()
          Set @AuthReason = @Msg
        end
      exec spi_InsWiresComplianceHold @WireGUID ,4,@AuthDate,@AuthBy,@ofac_id,@AuthReason,@Sender_id,@OnholdWireStatus,0
     end
--*/
-- Search for Beneficiary in OFAC List
  exec WireCompliance.dbo.sps_OFAC_CheckNames @ReceiverFirstName, @ReceiverLastName, @RcvCountry, 0, 'R',@Receiver_id,@OnholdWireStatus output, @Ofac_id output, @Msg output
  IF @Ofac_id IS NOT NULL                                                   
   BEGIN                                                                    
      if @OnholdWireStatus = 'P'
        begin
          SET @TransfStsComplianceOk = 0
          Set @AuthBy = null
          Set @AuthDate = null
          Set @AuthReason = null
        end
      else
        begin
          SET @TransfStsComplianceOk = 1
          Set @AuthBy = 'SYSTEM'
          Set @AuthDate = GetDate()
          Set @AuthReason = @Msg
        end
     exec spi_InsWiresComplianceHold @WireGUID ,5,@AuthDate,@AuthBy,@ofac_id,@AuthReason,@Sender_id,@OnholdWireStatus ,0
     END                                                                      

-- Search for Beneficiary in ALIAS (ALT) OFAC List
--/*
  exec WireCompliance.dbo.sps_OFAC_Check_ALT_Names @ReceiverFirstName, @ReceiverLastName, @RcvCountry, 'R',@Receiver_id,@OnholdWireStatus output, @Ofac_id output, @Msg output
  IF @Ofac_id IS NOT NULL                                                   
   BEGIN                                                                    
      if @OnholdWireStatus = 'P'
        begin
          SET @TransfStsComplianceOk = 0
          Set @AuthBy = null
          Set @AuthDate = null
          Set @AuthReason = null
        end
      else
        begin
          SET @TransfStsComplianceOk = 1
          Set @AuthBy = 'SYSTEM'
          Set @AuthDate = GetDate()
          Set @AuthReason = @Msg
        end
     exec spi_InsWiresComplianceHold @WireGUID ,5,@AuthDate,@AuthBy,@ofac_id,@AuthReason,@Sender_id,@OnholdWireStatus ,0
     END                                                                      
--*/
