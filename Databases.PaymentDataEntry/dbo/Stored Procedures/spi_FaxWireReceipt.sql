CREATE PROCEDURE [dbo].[spi_FaxWireReceipt] (@WireId int, @Fax1025 bit)
AS
BEGIN
	SET NOCOUNT ON;

    INSERT INTO dbo.WiresToFax with(rowlock) (WireId, Fax1025) values (@WireId, @Fax1025)
END
