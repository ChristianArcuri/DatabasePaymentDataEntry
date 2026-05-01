create FUNCTION [dbo].[GetVersion] (@AppVersion varchar(50))
RETURNS varchar(50)
AS
BEGIN
   DECLARE @R varchar(50), @Version varchar(50), @DotPos int

   Set @Version = LTRIM(RTRIM(@AppVersion))
   Set @DotPos = CHARINDEX (' ', @Version)
   
   Set @R = rtrim(SUBSTRING(@Version, 1, @DotPos))

  Return @R;
END