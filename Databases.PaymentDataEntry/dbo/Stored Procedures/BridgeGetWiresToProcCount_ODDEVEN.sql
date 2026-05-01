CREATE procedure [dbo].[BridgeGetWiresToProcCount_ODDEVEN] @EvenWireId bit
as
  set nocount on;
  
  SELECT COUNT(*) AS WireToProc
  FROM Wires as W with(nolock) 
     JOIN ProcessedWires as P with(nolock) on W.WireId = P.WireId
  WHERE Done=0 and dbo.fn_IsEvenNumber(W.WireId) = @EvenWireId
     and not Exists(select * from dbo.WirePossibleFraud T01 with(nolock) where T01.WireId = W.WireId and (Ok is null or Ok = 0))
