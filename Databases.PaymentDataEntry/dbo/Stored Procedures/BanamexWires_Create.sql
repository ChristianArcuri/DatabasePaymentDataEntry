create procedure dbo.BanamexWires_Create
@WireId int,
@PromotionId int
AS
BEGIN
  INSERT INTO BanamexWires (WireId,PromotionId)
    VALUES (@WireId,@PromotionId)
END