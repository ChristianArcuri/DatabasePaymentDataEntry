CREATE procedure [dbo].[ArchiveWiresCFPBLog]
as
  set nocount on;
    
declare @D datetime, @ArchD date, @ID int

select @D = DATEADD(DAY, -7, Cast(GETDATE() as Date)),
       @ArchD = CAST(GetDate() as Date)

insert into [192.168.1.135].DataEntryArchives.dbo.WiresCFPBLog with(tablock) 
          (CFPBLogId, WireTAG, SenderId, ReceiverId, WireDatetime, AmountToBeTransferred, 
           FrontEndFee, Taxes, ExchangeRate, BackEndFeeTaxes, TotalAmountToBeReceived, 
           AgPayerCode, AgSenderCode, BranchId, AgentName, SenderName, AgSenderSeq, Action, 
           UserName, Created)
	select CFPBLogId, WireTAG, SenderId, ReceiverId, WireDatetime, AmountToBeTransferred, 
           FrontEndFee, Taxes, ExchangeRate, BackEndFeeTaxes, TotalAmountToBeReceived, 
           AgPayerCode, AgSenderCode, BranchId, AgentName, SenderName, AgSenderSeq, Action, 
           UserName, Created
    --select COUNT(*)
	from WiresCFPBLog T1
	where Created < @D and 
		  not Exists(select * from [192.168.1.135].DataEntryArchives.dbo.WiresCFPBLog T02 where T02.CFPBLogId = T1.CFPBLogId)
    order by CFPBLogId
    
declare @Finish bit = 0, @i int

declare curArchTags cursor for
  select CFPBLogId --8736158
  from [192.168.1.135].DataEntryArchives.dbo.WiresCFPBLog T1
  where Archived = @ArchD 
     and Exists(select * from WiresCFPBLog T01 where T1.CFPBLogId = T01.CFPBLogId)
  order by T1.CFPBLogId

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
       
    delete from WiresCFPBLog with(rowlock)
    where CFPBLogId in (select ID from @IDList)
    
    if @Finish = 1
      break
      
    delete from @IDList  
  end
  
  close curArchTags
  deallocate curArchTags;
  