CREATE FUNCTION [dbo].[IsAppSignValid] (@AppVersion varchar(50), @Token int)
RETURNS bit
AS
BEGIN
   DECLARE @R bit, @Version varchar(50), @VersionCRC32 int

   select @Version = dbo.GetVersion(@AppVersion)
   
   select @VersionCRC32 = CRC32
   from WireSearch.dbo.AppVersions
   where AppVersion = @Version

   if @Token = @VersionCRC32
    Set @R = 1
   else 
    Set @R = 0
   
  Return @R;
END