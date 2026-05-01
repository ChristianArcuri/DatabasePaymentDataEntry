CREATE PROCEDURE [dbo].[WebAgent_VoidPaymentDataEntry]
@WireId int,
@CancelReasonId int
AS
BEGIN
  set nocount on;

  UPDATE Wires with(rowlock) SET StsCancel = 1, CancelReasonId = @CancelReasonId
  WHERE WireID = @WireId

   --Ver que mas.Cashdirect lo esta usando para cancelar PIN Debit transactions
END