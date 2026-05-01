create FUNCTION [dbo].[GetBuildNo] (@AppVersion varchar(50))
RETURNS varchar(20)
AS
BEGIN
   DECLARE @R varchar(20), @Version varchar(50), @DotPos int

   Set @Version = LTRIM(RTRIM(@AppVersion))
   Set @DotPos = CHARINDEX ('.', REVERSE(@Version))
   
   Set @R = rtrim(SUBSTRING(@Version, LEN(@Version) - @DotPos + 2, 4))

  Return @R;
END