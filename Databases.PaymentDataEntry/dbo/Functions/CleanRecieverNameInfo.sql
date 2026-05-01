CREATE FUNCTION CleanRecieverNameInfo(@inputString VARCHAR(50))
RETURNS VARCHAR(50)
AS
     BEGIN
         DECLARE @increment INT= 1;
		 DECLARE @asciiCode INT;
		 DECLARE @char VARCHAR;
         WHILE @increment <= DATALENGTH(@inputString)
             BEGIN
				 SET @asciiCode = ASCII(SUBSTRING(@inputString, @increment, 1));
                 IF NOT((@asciiCode BETWEEN 97 AND 122) OR (@asciiCode BETWEEN 65 AND 90) OR (@asciiCode = 32) )
					BEGIN
						SET @char = dbo.GetReplaceCharForAsciiCode(@asciiCode);	
                        SET @inputString = REPLACE(@inputString, CHAR(@asciiCode), @char);
					END
                 SET @increment = @increment + 1;
             END
         RETURN @inputString;
     END