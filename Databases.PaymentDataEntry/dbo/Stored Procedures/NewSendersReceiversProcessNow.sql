CREATE procedure NewSendersReceiversProcessNow
as
  set nocount on;
  
  select cast(DoItNow as int) as DoIt from BridgeProcessNow


