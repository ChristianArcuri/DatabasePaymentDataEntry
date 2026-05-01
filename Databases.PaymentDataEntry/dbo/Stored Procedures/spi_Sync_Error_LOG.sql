
CREATE PROCEDURE [dbo].[spi_Sync_Error_LOG] @ProcessName varchar(50)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @ERROR_MSG varchar(max)
  
  select @ERROR_MSG = 'Line No.: ' + CAST(ERROR_LINE() as varchar) + ' Error: ' + ERROR_MESSAGE()

  INSERT INTO SyncErrorLog (Process, ErrMsg) values(@ProcessName, @ERROR_MSG)
  
  RAISERROR (@ERROR_MSG , 16, 1)
END

