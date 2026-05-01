CREATE FUNCTION [dbo].[fn_IsEvenNumber] (@N int)  
RETURNS bit AS  
BEGIN 
--hola
  DECLARE @Result bit
  
  if (@N % 2) = 0
    Set @Result = 1
  else
    Set @Result = 0
  
  return @Result
END
