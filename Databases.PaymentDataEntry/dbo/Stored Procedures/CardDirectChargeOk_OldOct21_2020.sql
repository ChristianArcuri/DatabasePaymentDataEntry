CREATE procedure [dbo].[CardDirectChargeOk_OldOct21_2020](@WireId int, @CardChargeId int, @CardDirectProvider int)
as
  set nocount on;

  update Wires with(rowlock) 
    set CardChargeId = @CardChargeId, 
	    CardDirectProvider = @CardDirectProvider
  where WireId = @WireId

  if not Exists(select * from ProcessedWires where WireID = @WireId)
    INSERT INTO ProcessedWires with(rowlock) (WireID, Done) Values(@WireID, 0)

