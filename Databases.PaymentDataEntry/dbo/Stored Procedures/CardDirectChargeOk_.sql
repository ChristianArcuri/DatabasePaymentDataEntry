
CREATE procedure [dbo].[CardDirectChargeOk_](@WireId int, @CardChargeId int, @CardDirectProvider int)
as
  set nocount on;

  INSERT INTO CardDirectProcessLog (WireId,SPName ,Created ,ActionDescription ,SenderPaymentMethodID ,CardChargeId)
                            VALUES (@WireId,'CardDirectChargeOk_',getdate(),'CardDirectChargeOk_', 5,@CardChargeId )


  update Wires with(rowlock) 
    set CardChargeId = @CardChargeId, 
	    CardDirectProvider = @CardDirectProvider,
		SenderPaymentMethodID = 5
  where WireId = @WireId

  if not Exists(select * from ProcessedWires where WireID = @WireId)
    INSERT INTO ProcessedWires with(rowlock) (WireID, Done) Values(@WireID, 0)

