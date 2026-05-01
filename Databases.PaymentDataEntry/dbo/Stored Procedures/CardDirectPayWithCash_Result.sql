
CREATE PROCEDURE [dbo].[CardDirectPayWithCash_Result]
	@WireId int, 
	@WireTotalAmount money,
	@ChangedToCashOK bit OUTPUT
AS
BEGIN
  set nocount on;
  DECLARE @RecordId INT
  DECLARE @CardChargeId int

  SET @ChangedToCashOK = 0

  INSERT INTO CardDirectProcessLog (WireId,SPName ,Created ,ActionDescription ,SenderPaymentMethodID ,CardChargeId)
                            VALUES (@WireId,'CardDirectPayWithCash',getdate(),'PayWithCash', 1,0 )
  SET @RecordId = SCOPE_IDENTITY()


  SELECT TOP 1 @CardChargeId = r.ResultId
	FROM  Card_CenPosResults as r
		INNER JOIN WiresTAG as t on r.WireTAG = t.WireTAG
	WHERE @WireId = t.WireId
		AND r.ResponseResult = 0
    ORDER BY r.ResultId DESC
	IF @@ROWCOUNT = 0
	   SET @CardChargeId = 0


  update Wires with(rowlock) 
    set SenderPaymentMethodId = 1,
        CashBackAmount = 0.00,
        TransacTotalAmount = 0,
        WireSenderPaymentMethodFee = 0,
        WireTotalAmount = @WireTotalAmount
  where WireId = @WireId
    and ISNULL(@CardChargeId, 0) = 0

	IF @@ROWCOUNT = 0
	   BEGIN
		 UPDATE CardDirectProcessLog SET ActionDescription = 'PayWithCash - Not Updated', SenderPaymentMethodID = 5
		  WHERE RecordId = @RecordId

		  EXEC CardDirectChargeOk_ @WireId , @CardChargeId , 2 --CenPos
	   END
	ELSE SET @ChangedToCashOK = 1

	                
	if not Exists(select * from ProcessedWires where WireID = @WireId)
	   INSERT INTO ProcessedWires with(rowlock) (WireID, Done) Values(@WireID, 0)
END