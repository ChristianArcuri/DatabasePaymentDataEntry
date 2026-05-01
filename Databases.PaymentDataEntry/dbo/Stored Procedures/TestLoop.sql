create procedure TestLoop
as
  set nocount on;

  declare @i int = 0

  while @i < 1000000
  begin
    Set @i = @i + 1
  end