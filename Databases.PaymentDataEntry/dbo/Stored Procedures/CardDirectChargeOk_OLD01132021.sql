
CREATE PROCEDURE [dbo].[CardDirectChargeOk_OLD01132021](@WireId INT, @CardChargeId INT, @CardDirectProvider INT)
AS
  SET NOCOUNT ON;

  INSERT INTO CardDirectProcessLog (WireId,SPName ,Created ,ActionDescription ,SenderPaymentMethodID ,CardChargeId)
                            VALUES (@WireId,'CardDirectChargeOk_',GETDATE(),'CardDirectChargeOk_', 5,@CardChargeId )


  UPDATE Wires WITH(ROWLOCK) 
    SET CardChargeId = @CardChargeId, 
	    CardDirectProvider = @CardDirectProvider
  WHERE WireId = @WireId

  IF NOT EXISTS(SELECT * FROM ProcessedWires WHERE WireID = @WireId)
    INSERT INTO ProcessedWires WITH(ROWLOCK) (WireID, Done) VALUES(@WireID, 0)

