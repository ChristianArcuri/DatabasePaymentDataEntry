CREATE FUNCTION [dbo].[IsReplWire] (@AppVersion varchar(50))
RETURNS bit
AS
BEGIN
   DECLARE @R bit, @Version varchar(50), @L int

   Set @Version = LTRIM(RTRIM(@AppVersion))
   Set @L = LEN(@Version)
   
   if SUBSTRING(@Version, @L, 1) = 'R'
     Set @R = 1
   else
     Set @R = 0

  Return @R;
END