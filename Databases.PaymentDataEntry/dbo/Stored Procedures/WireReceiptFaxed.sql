CREATE PROCEDURE WireReceiptFaxed (@WireId int)
AS
BEGIN
	SET NOCOUNT ON;

    UPDATE dbo.WiresToFax with(updlock) Set Faxed = GETDATE()
    WHERE WireId = @WireId
END
