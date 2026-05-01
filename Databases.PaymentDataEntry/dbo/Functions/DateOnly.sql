create   FUNCTION [dbo].[DateOnly] (@Date datetime)  
RETURNS datetime AS  
BEGIN 
DECLARE @Result datetime
set @Result = convert(datetime,convert(varchar,@Date,101))
return @Result
END
