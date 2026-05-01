
CREATE PROCEDURE CardDirect_CheckWireIsVoid
   @WireId int,
   @IsVoid bit output
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @StsCancel int

  SET @IsVoid = 0

  SELECT @StsCancel = StsCancel 
  FROM Wires 
  WHERE WireId = @WireID

  IF ISNULL(@StsCancel, 0) > 0
	SET @IsVoid = 1
END
