CREATE PROCEDURE spi_Error_LOG @ProcessName varchar(30)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @ERROR_MSG varchar(max)
  
  select @ERROR_MSG = 'Line No.: ' + CAST(ERROR_LINE() as varchar) + ' Error: ' + ERROR_MESSAGE()

  INSERT INTO dbo.ErrorLog (ProcessName, ErrorMsg) values(@ProcessName, @ERROR_MSG)
  
  RAISERROR (@ERROR_MSG , 16, 1)
END
