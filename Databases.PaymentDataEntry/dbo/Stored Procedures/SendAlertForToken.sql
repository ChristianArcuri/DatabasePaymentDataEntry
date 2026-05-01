create Procedure SendAlertForToken
as
  set nocount on;
  
insert into dbo.AppTokenErrors(WireID)
	select WireId
	from Wires T1 with(nolock)
	where SourceApp = 6 and WireDatetime > DateAdd(hour, -8, GETDATE()) and 
		  dbo.IsReplWire(AppVersion) = 0 and 
		  dbo.GetBuildNo(AppVersion) >= '452' and
		  dbo.IsAppSignValid(AppVersion, PayerSecToken) = 0 and
		  not Exists(select * from AppTokenErrors T01 where T01.WireId = T1.WireId)
	order by WireId

 declare @WireId int, @MsgId int
 
 declare curAlerts cursor for
   select WireId 
   from AppTokenErrors
   where Notified is null
   
 Open curAlerts
 
 while (1=1)
  begin
     FETCH NEXT FROM curAlerts INTO @WireId;
     if @@FETCH_STATUS <> 0 
       Break
    
		EXEC WireSearch.dbo.SendEmail
				@SenderEmail = 'alert@example.com',
				@SenderName = 'Fraude Alert',
				@Email = 'aibarra@Intemexusa.com',
				@Subject = 'Fraude Alert. Incorrect Token',
				@MsgBody = 'There is a new Alert in the DE. Token incorrect.',
				@Tag = NULL,
				@MsgId = @MsgId OUTPUT     
    
     update AppTokenErrors set Notified = GETDATE()
     where WireId = @WireId 
  end
  
 Close curAlerts
 Deallocate curAlerts 
   

