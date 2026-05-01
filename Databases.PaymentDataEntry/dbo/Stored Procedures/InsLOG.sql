create procedure [dbo].[InsLOG](@IP varchar(50), @Process int, @Tag varchar(50))
as
  set nocount on;
  
  insert into dbo.ConnLog with(rowlock)(IP, Process, Tag)
  values(@IP, @Process, @Tag)
