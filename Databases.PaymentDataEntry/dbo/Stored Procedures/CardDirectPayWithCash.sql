create procedure [dbo].[CardDirectPayWithCash](@WireId int, @WireTotalAmount money)
as
  set nocount on;

  update Wires with(rowlock) 
    set SenderPaymentMethodId = 1,
        CashBackAmount = 0.00,
        TransacTotalAmount = 0,
        WireSenderPaymentMethodFee = 0,
        WireTotalAmount = @WireTotalAmount
  where WireId = @WireId

  INSERT INTO ProcessedWires with(rowlock) (WireID, Done) Values(@WireID, 0)
