CREATE procedure [dbo].[ArchiveSP_ConnLog]
as
  set nocount on;
  
declare @D datetime, @ArchD date, @ID int

select @D = DATEADD(DAY, -7, Cast(GETDATE() as Date)),
       @ArchD = CAST(GetDate() as Date)

insert into [192.168.1.135].DataEntryArchives.dbo.ConnLog with(tablock) 
          (ID, IP, Process, Tag, Created)
	select ID, IP, Process, Tag, Created
	from ConnLog T1
	where Created < @D and 
		  not Exists(select * from [192.168.1.135].DataEntryArchives.dbo.ConnLog T02 where T02.ID = T1.ID)
    order by ID
    
declare @Finish bit = 0, @i int

declare curArchTags cursor for
  select ID --8736158
  from [192.168.1.135].DataEntryArchives.dbo.ConnLog T1
--  where T1.ID between 1 and 5325234 and Exists(select * from WiresTAG T01 where T1.id = T01.ID)
  where Archived = @ArchD 
     and Exists(select * from ConnLog T01 where T1.ID = T01.ID)
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
       
    delete from ConnLog with(rowlock)
    where ID in (select ID from @IDList)
    
    if @Finish = 1
      break
      
    delete from @IDList  
  end
  
  close curArchTags
  deallocate curArchTags;
  