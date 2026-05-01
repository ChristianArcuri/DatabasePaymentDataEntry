create PROCEDURE [dbo].[spi_Error_LOG2] @ProcessName varchar(30), @WireInfoForLog varchar(max)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @ERROR_MSG varchar(max)
  
  SET @ERROR_MSG = 'Line No.: ' + CAST(ERROR_LINE() as varchar) + ' Error: ' + ERROR_MESSAGE()

  SET @ERROR_MSG = @WireInfoForLog + ' ' + IsNull(@ERROR_MSG, '')

  INSERT INTO dbo.ErrorLog (ProcessName, ErrorMsg) values(@ProcessName, @ERROR_MSG)
  
  RAISERROR (@ERROR_MSG , 16, 1)
END
