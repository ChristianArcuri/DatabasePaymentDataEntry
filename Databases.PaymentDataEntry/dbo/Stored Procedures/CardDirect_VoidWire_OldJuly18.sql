CREATE procedure [dbo].[CardDirect_VoidWire_OldJuly18] @WireId int
as
BEGIN
  set nocount on;

  exec WebAgent_VoidPaymentDataEntry @WireId, 57 --CARD DIRECT - COLLECTION FAIL 

  insert into ProcessedWires(WireID) values(@WireId)

END