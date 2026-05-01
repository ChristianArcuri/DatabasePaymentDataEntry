CREATE PROCEDURE [dbo].[WebAgent_WireInPreparation_Create]
@PreparationId UniqueIdentifier OUTPUT
AS
BEGIN
  SET @PreparationId = newid()
  INSERT INTO WebAgent_WireInPreparation
							   (PreparationId               )
						VALUES
							(  @PreparationId     )
END