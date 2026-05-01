CREATE FUNCTION [dbo].[GetCurrentIP] ()
RETURNS varchar(50)
AS
BEGIN
   DECLARE @IP_Address varchar(50) = '';

   --SELECT @IP_Address = client_net_address
   --FROM sys.dm_exec_connections
   --WHERE Session_id = @@SPID;
    select @IP_Address = cast(CONNECTIONPROPERTY('client_net_address') as varchar(50))

  Return @IP_Address;
END
