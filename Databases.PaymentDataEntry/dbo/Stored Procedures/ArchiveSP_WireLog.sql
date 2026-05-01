CREATE procedure [dbo].[ArchiveSP_WireLog]
as
  set nocount on;
  
declare @D datetime, @ArchD date, @ID int

select @D = DATEADD(DAY, -7, Cast(GETDATE() as Date)),
       @ArchD = CAST(GetDate() as Date)

insert into [192.168.1.135].DataEntryArchives.dbo.SP_WireLog with(tablock) 
      (RecordId, AgSenderCode, SenderName, ReceiverName, OriAmount, AgPayerCode, CreatedBy, WireDateTime, ComputerName, IPAddress, UserName, SP)
	select RecordId, AgSenderCode, SenderName, ReceiverName, OriAmount, AgPayerCode, CreatedBy, WireDateTime, ComputerName, IPAddress, UserName, SP
	from SP_WireLog T1
	where WireDateTime < @D and 
		  not Exists(select * from [192.168.1.135].DataEntryArchives.dbo.SP_WireLog T02 where T02.RecordId = T1.RecordId)
    order by RecordId
    
declare @Finish bit = 0, @i int

declare curArchTags cursor for
  select RecordId --8736158
  from [192.168.1.135].DataEntryArchives.dbo.SP_WireLog T1
--  where T1.ID between 1 and 5325234 and Exists(select * from WiresTAG T01 where T1.id = T01.ID)
  where Archived = @ArchD 
     and Exists(select * from SP_WireLog T01 where T1.RecordId = T01.RecordId)
  order by T1.RecordId

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
       
    delete from SP_WireLog with(rowlock)
    where RecordId in (select ID from @IDList)
    
    if @Finish = 1
      break
      
    delete from @IDList  
  end
  
  close curArchTags
  deallocate curArchTags;
  