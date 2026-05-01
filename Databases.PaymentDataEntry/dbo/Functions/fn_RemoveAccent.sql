CREATE FUNCTION dbo.fn_RemoveAccent(@Name varchar(150))
RETURNS varchar(150)
AS
BEGIN

set @name = REPLACE(@name,'á','a')
set @name = REPLACE(@name,'é','e')
set @name = REPLACE(@name,'í','i')
set @name = REPLACE(@name,'ó','o')
set @name = REPLACE(@name,'ú','u')

RETURN @name

END