CREATE FUNCTION [dbo].[CleanWhiteSpaces]
(
    @inputString VARCHAR(max)
)
RETURNS VARCHAR(max)
AS

BEGIN
    DECLARE @outputString varchar(100)
    SET @outputString = @inputString
    
    while charindex('  ', @outputString  ) > 0
    begin
       set @outputString = replace(@outputString, '  ', ' ')
    end
    
    RETURN RTRIM(LTRIM(@outputString));
END