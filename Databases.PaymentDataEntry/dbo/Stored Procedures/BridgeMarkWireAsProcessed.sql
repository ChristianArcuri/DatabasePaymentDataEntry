CREATE procedure [dbo].[BridgeMarkWireAsProcessed] (@WireId int, @Control int)
as
  set nocount on;

  UPDATE ProcessedWires with(updlock) 
    SET Done = 1, 
        Control = @Control
  WHERE WireID = @WireId