create procedure [dbo].[CardDirectChargeOk](@WireId int, @CardChargeId int)
as
  set nocount on;

  update Wires with(rowlock) set CardChargeId = @CardChargeId
  where WireId = @WireId

  INSERT INTO ProcessedWires with(rowlock) (WireID, Done) Values(@WireID, 0)

