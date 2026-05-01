


create PROCEDURE [dbo].[spi_InsWiresComplianceHold] 
          @WireGUID uniqueidentifier,
          @OnHoldReason_id int,
          @AuthoDate datetime,
          @AuthoUserName varchar(15),
          @DenyOfac_id int,
          @Comment varchar(255),
          @Sender_id int,
          @Status char(1),
          @Amount money
as
  set nocount on

 IF EXISTS (SELECT * 
            FROM WiresComplianceHold   with(nolock) 
            WHERE WireGUID = @WireGUID
               AND Status = 'P'
               AND OnHoldReason_Id = @OnHoldReason_id)
     RETURN


 INSERT INTO WiresComplianceHold with(rowlock) 
             (WireGUID, OnHoldReason_Id,  DenyOfac_id,  Status,  AuthoUserName,   AuthoDate , Comment, Sender_id, Amount) 
     VALUES (@WireGUID, @OnHoldReason_Id, @DenyOfac_id, @Status, @AuthoUserName,  @AuthoDate, @Comment, @Sender_id,@Amount)


