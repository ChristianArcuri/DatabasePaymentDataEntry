CREATE  FUNCTION [dbo].[JustNum] (@StrPrm varchar(255))
RETURNS varchar(255) AS  
BEGIN 
DECLARE @RetVal varchar(255)
DECLARE @TmpVal varchar(255)
DECLARE @Sub varchar(1)
DECLARE @I int 
DECLARE @L int
  SET @TmpVal = LTRIM(RTRIM(@StrPrm))
  SET @RetVal = ''
  SET @L = LEN(@TmpVal)  
  SET @I = 1
  WHILE @I <= @L
    BEGIN
      SET @Sub = SUBSTRING(@TmpVal,@I,1)
      IF @Sub in ('0','1','2','3','4','5','6','7','8','9') 
       SET @RetVal = @RetVal + @Sub
      SET @I = @I + 1
    END
  RETURN @RetVal  
END
