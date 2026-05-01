CREATE FUNCTION [dbo].[GetReplaceCharForAsciiCode](@asciiCode INT)
RETURNS VARCHAR
AS
	BEGIN
		DECLARE @result VARCHAR;
		SET @result =	CASE 
							WHEN @asciiCode BETWEEN 192 AND 197 THEN 'A'
							WHEN @asciiCode BETWEEN 200 AND 203 THEN 'E'
							WHEN @asciiCode BETWEEN 204 AND 207 THEN 'I'
							WHEN @asciiCode BETWEEN 210 AND 214 THEN 'O'
							WHEN @asciiCode BETWEEN 217 AND 220 THEN 'U'
							WHEN @asciiCode BETWEEN 224 AND 229 THEN 'a'			
							WHEN @asciiCode BETWEEN 232 AND 235 THEN 'e'			
							WHEN @asciiCode BETWEEN 236 AND 239 THEN 'i'			
							WHEN @asciiCode BETWEEN 242 AND 246 THEN 'o'			
							WHEN @asciiCode BETWEEN 249 AND 252 THEN 'u'			
							WHEN @asciiCode = 241 THEN 'n'
							WHEN @asciiCode = 209 THEN 'N'
							WHEN @asciiCode = 253 OR @asciiCode = 255 THEN 'y'
							WHEN @asciiCode = 159 OR @asciiCode = 221 THEN 'Y'
							WHEN @asciiCode = 199 THEN 'C'
							WHEN @asciiCode = 231 THEN 'c'
							WHEN @asciiCode = 208 THEN 'D'
							ELSE ''
						END;
		return @result;
	END

	--LEGEND of Specials Characters
--select ASCII('ó') as 'ASCII', CHAR(ASCII('ó')) as 'CHAR'
--union 
--select ASCII('ò') as 'ASCII', CHAR(ASCII('ò')) as 'CHAR'
--union 
--select ASCII('ö') as 'ASCII', CHAR(ASCII('ö')) as 'CHAR'
--union 
--select ASCII('ð') as 'ASCII', CHAR(ASCII('ð')) as 'CHAR'
--union 
--select ASCII('ô') as 'ASCII', CHAR(ASCII('ô')) as 'CHAR'
--union 
--select ASCII('õ') as 'ASCII', CHAR(ASCII('õ')) as 'CHAR'
--union 
--select ASCII('×') as 'ASCII', CHAR(ASCII('×')) as 'CHAR'
--union 
--select ASCII('f') as 'ASCII', CHAR(ASCII('f')) as 'CHAR'
--union 
--select ASCII('Ò') as 'ASCII', CHAR(ASCII('Ò')) as 'CHAR'
--union 
--select ASCII('Ó') as 'ASCII', CHAR(ASCII('Ó')) as 'CHAR'
--union 
--select ASCII('Ô') as 'ASCII', CHAR(ASCII('Ô')) as 'CHAR'
--union 
--select ASCII('Õ') as 'ASCII', CHAR(ASCII('Õ')) as 'CHAR'
--union 
--select ASCII('Ö') as 'ASCII', CHAR(ASCII('Ö')) as 'CHAR'
--union 
--select ASCII('ñ') as 'ASCII', CHAR(ASCII('ñ')) as 'CHAR'
--union 
--select ASCII('Ñ') as 'ASCII', CHAR(ASCII('Ñ')) as 'CHAR'
--union 
--select ASCII('è') as 'ASCII', CHAR(ASCII('è')) as 'CHAR'
--union 
--select ASCII('é') as 'ASCII', CHAR(ASCII('é')) as 'CHAR'
--union 
--select ASCII('ê') as 'ASCII', CHAR(ASCII('ê')) as 'CHAR'
--union 
--select ASCII('ë') as 'ASCII', CHAR(ASCII('ë')) as 'CHAR'
--union 
--select ASCII('È') as 'ASCII', CHAR(ASCII('È')) as 'CHAR'
--union 
--select ASCII('É') as 'ASCII', CHAR(ASCII('É')) as 'CHAR'
--union 
--select ASCII('Ê') as 'ASCII', CHAR(ASCII('Ê')) as 'CHAR'
--union 
--select ASCII('Ë') as 'ASCII', CHAR(ASCII('Ë')) as 'CHAR'
--union 
--select ASCII('á') as 'ASCII', CHAR(ASCII('á')) as 'CHAR'
--union 
--select ASCII('ã') as 'ASCII', CHAR(ASCII('ã')) as 'CHAR'
--union 
--select ASCII('â') as 'ASCII', CHAR(ASCII('â')) as 'CHAR'
--union 
--select ASCII('à') as 'ASCII', CHAR(ASCII('à')) as 'CHAR'
--union 
--select ASCII('ä') as 'ASCII', CHAR(ASCII('ä')) as 'CHAR'
--union 
--select ASCII('å') as 'ASCII', CHAR(ASCII('å')) as 'CHAR'
--union 
--select ASCII('ª') as 'ASCII', CHAR(ASCII('ª')) as 'CHAR'
--union 
--select ASCII('æ') as 'ASCII', CHAR(ASCII('æ')) as 'CHAR'
--union 
--select ASCII('À') as 'ASCII', CHAR(ASCII('À')) as 'CHAR'
--union 
--select ASCII('Á') as 'ASCII', CHAR(ASCII('Á')) as 'CHAR'
--union 
--select ASCII('Â') as 'ASCII', CHAR(ASCII('Â')) as 'CHAR'
--union 
--select ASCII('Ã') as 'ASCII', CHAR(ASCII('Ã')) as 'CHAR'
--union 
--select ASCII('Å') as 'ASCII', CHAR(ASCII('Å')) as 'CHAR'
--union 
--select ASCII('Ä') as 'ASCII', CHAR(ASCII('Ä')) as 'CHAR'
--union 
--select ASCII('Æ') as 'ASCII', CHAR(ASCII('Æ')) as 'CHAR'
--union 
--select ASCII('æ') as 'ASCII', CHAR(ASCII('æ')) as 'CHAR'
--union 
--select ASCII('ù') as 'ASCII', CHAR(ASCII('ù')) as 'CHAR'
--union 
--select ASCII('ú') as 'ASCII', CHAR(ASCII('ú')) as 'CHAR'
--union 
--select ASCII('û') as 'ASCII', CHAR(ASCII('û')) as 'CHAR'
--union 
--select ASCII('ü') as 'ASCII', CHAR(ASCII('ü')) as 'CHAR'
--union 
--select ASCII('µ') as 'ASCII', CHAR(ASCII('µ')) as 'CHAR'
--union 
--select ASCII('Ù') as 'ASCII', CHAR(ASCII('Ù')) as 'CHAR'
--union 
--select ASCII('Ú') as 'ASCII', CHAR(ASCII('Ú')) as 'CHAR'
--union 
--select ASCII('Û') as 'ASCII', CHAR(ASCII('Û')) as 'CHAR'
--union 
--select ASCII('Ü') as 'ASCII', CHAR(ASCII('Ü')) as 'CHAR'
--union 
--select ASCII('Ý') as 'ASCII', CHAR(ASCII('Ý')) as 'CHAR'
--union 
--select ASCII('Ÿ') as 'ASCII', CHAR(ASCII('Ÿ')) as 'CHAR'
--union 
--select ASCII('ÿ') as 'ASCII', CHAR(ASCII('ÿ')) as 'CHAR'
--union 
--select ASCII('ý') as 'ASCII', CHAR(ASCII('ý')) as 'CHAR'
--union 
--select ASCII('þ') as 'ASCII', CHAR(ASCII('þ')) as 'CHAR'
--union 
--select ASCII('Ç') as 'ASCII', CHAR(ASCII('Ç')) as 'CHAR'
--union 
--select ASCII('ç') as 'ASCII', CHAR(ASCII('ç')) as 'CHAR'
--union 
--select ASCII('œ') as 'ASCII', CHAR(ASCII('œ')) as 'CHAR'
--union 
--select ASCII('Œ') as 'ASCII', CHAR(ASCII('Œ')) as 'CHAR'
--union 
--select ASCII('Ì') as 'ASCII', CHAR(ASCII('Ì')) as 'CHAR'
--union 
--select ASCII('Í') as 'ASCII', CHAR(ASCII('Í')) as 'CHAR'
--union 
--select ASCII('Î') as 'ASCII', CHAR(ASCII('Î')) as 'CHAR'
--union 
--select ASCII('Ï') as 'ASCII', CHAR(ASCII('Ï')) as 'CHAR'
--union 
--select ASCII('ì') as 'ASCII', CHAR(ASCII('ì')) as 'CHAR'
--union 
--select ASCII('í') as 'ASCII', CHAR(ASCII('í')) as 'CHAR'
--union 
--select ASCII('î') as 'ASCII', CHAR(ASCII('î')) as 'CHAR'
--union 
--select ASCII('ï') as 'ASCII', CHAR(ASCII('ï')) as 'CHAR'
--union 
--select ASCII('Ð') as 'ASCII', CHAR(ASCII('Ð')) as 'CHAR'
--union 
--select ASCII('ß') as 'ASCII', CHAR(ASCII('ß')) as 'CHAR'
--union 
--select ASCII('Š') as 'ASCII', CHAR(ASCII('Š')) as 'CHAR'
--union 
--select ASCII('š') as 'ASCII', CHAR(ASCII('š')) as 'CHAR'
--union 
--select ASCII('§') as 'ASCII', CHAR(ASCII('§')) as 'CHAR'
--union 
--select ASCII('½') as 'ASCII', CHAR(ASCII('½')) as 'CHAR'
--union 
--select ASCII('¼') as 'ASCII', CHAR(ASCII('¼')) as 'CHAR'
--union 
--select ASCII('¾') as 'ASCII', CHAR(ASCII('¾')) as 'CHAR'
--union 
--select ASCII('©') as 'ASCII', CHAR(ASCII('©')) as 'CHAR'
--union 
--select ASCII('®') as 'ASCII', CHAR(ASCII('®')) as 'CHAR'
--union 
--select ASCII('‰') as 'ASCII', CHAR(ASCII('‰')) as 'CHAR'
--union 
--select ASCII('¿') as 'ASCII', CHAR(ASCII('¿')) as 'CHAR'
--union 
--select ASCII('º') as 'ASCII', CHAR(ASCII('º')) as 'CHAR'
--union 
--select ASCII('¹') as 'ASCII', CHAR(ASCII('¹')) as 'CHAR'
--union 
--select ASCII('²') as 'ASCII', CHAR(ASCII('²')) as 'CHAR'
--union 
--select ASCII('³') as 'ASCII', CHAR(ASCII('³')) as 'CHAR'
--union 
--select ASCII('-') as 'ASCII', CHAR(ASCII('-')) as 'CHAR'