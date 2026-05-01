CREATE procedure [dbo].[BridgeGetWiresToProcCount]
as
  set nocount on;
  
  SELECT COUNT(*) AS WireToProc
  FROM Wires as W  
     JOIN ProcessedWires as P with(nolock) on W.WireId = P.WireId
  WHERE Done=0 
     and not Exists(select * from dbo.WirePossibleFraud T01 with(nolock) where T01.WireId = W.WireId and (Ok is null or Ok = 0))

      