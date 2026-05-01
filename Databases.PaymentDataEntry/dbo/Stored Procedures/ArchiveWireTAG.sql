CREATE procedure [dbo].[ArchiveWireTAG]
as
  set nocount on;

declare @D datetime, @ArchD date, @ID int

select @D = DATEADD(DAY, -7, Cast(GETDATE() as Date)),
       @ArchD = CAST(GetDate() as Date)

insert into [192.168.1.135].DataEntryArchives.dbo.WiresTAG with(tablock) (ID, WireTAG, WireID, PswHash, AppHash, AgComputerid, Created)
	select ID, WireTAG, WireID, PswHash, AppHash, AgComputerid, Created
	from WiresTAG T1
	where Created < @D and 
		  not Exists(select * from Wires T01 where T1.WireID = T01.WireId) and
		  not Exists(select * from [192.168.1.135].DataEntryArchives.dbo.WiresTAG T02 where T02.ID = T1.ID)

--select Archived, COUNT(*)
--from [192.168.1.135].DataEntryArchives.dbo.WiresTAG 
--group by Archived
--order by Archived

--5,325,234
--3,010,664
--select MIN(ID), MAX(ID)
--from [192.168.1.135].DataEntryArchives.dbo.WiresTAG 
--where Archived = '6/2/2014'

--select COUNT(*)
--from WiresTAG
--where ID between 1 and 5325234

--select COUNT(*) 
--from WiresTAG T1
--where Exists(select * from [192.168.1.135].DataEntryArchives.dbo.WiresTAG T01 where T1.ID = T01.ID and Archived = '6/2/2014')

declare @Finish bit = 0, @i int

declare curArchTags cursor for
  select ID
  from [192.168.1.135].DataEntryArchives.dbo.WiresTAG T1
--  where T1.ID between 1 and 5325234 and Exists(select * from WiresTAG T01 where T1.id = T01.ID)
  where Archived = @ArchD 
  order by T1.ID

  declare @IDList table (ID int)
  
  open curArchTags
  
  while 1=1
  begin
    Set @i = 1
    while @i <= 10000
    begin
   	  FETCH NEXT FROM curArchTags INTO @ID;
	  if @@FETCH_STATUS <> 0
	    begin
	      Set @Finish = 1
		  break
		end  
      
      insert into @IDList(ID) values (@ID)
      
      Set @I = @i + 1
    end 
       
    delete from WiresTAG with(rowlock)
    where ID in (select ID from @IDList)
    
    if @Finish = 1
      break
      
    delete from @IDList  
  end
  
  close curArchTags
  deallocate curArchTags;
  