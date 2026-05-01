CREATE procedure TestIP
as
  set nocount on 
  
  declare @IP varchar(50)
  
  select @IP = dbo.GetCurrentIP()
  
  insert into dbo.TEST(Msg) values(@IP)
  