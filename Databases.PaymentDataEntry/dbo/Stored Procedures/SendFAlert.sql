CREATE procedure  [dbo].[SendFAlert]
as
  set nocount on;
  
 declare curAlerts cursor for
  select RecordId
  from dbo.FAlert
  where Notified is null
 
  declare @AlertID int, @MsgId int
  
  Open curAlerts
  while (1=1)
   begin
     FETCH NEXT FROM curAlerts INTO @AlertID;
     if @@FETCH_STATUS <> 0 
       Break
     
		EXEC WireSearch.dbo.SendEmail
				@SenderEmail = 'alert@example.com',
				@SenderName = 'Fraude Alert',
				@Email = 'aibarra@Intemexusa.com',
				@Subject = 'Fraude Alert',
				@MsgBody = 'There is a new Alert in the DE',
				@Tag = NULL,
				@MsgId = @MsgId OUTPUT     

		EXEC WireSearch.dbo.SendEmail
				@SenderEmail = 'alert@example.com',
				@SenderName = 'Fraude Alert',
				@Email = 'gschnaider@example.com',
				@Subject = 'Fraude Alert',
				@MsgBody = 'There is a new Alert in the DE',
				@Tag = NULL,
				@MsgId = @MsgId OUTPUT     

		--EXEC WireSearch.dbo.SendEmail
		--		@SenderEmail = 'alert@example.com',
		--		@SenderName = 'Fraude Alert',
		--		@Email = 'evaldez@example.com',
		--		@Subject = 'Fraude Alert',
		--		@MsgBody = 'There is a new Alert in the DE',
		--		@Tag = NULL,
		--		@MsgId = @MsgId OUTPUT     
     
      update dbo.FAlert with(updlock) set Notified = GETDATE()
      where RecordId = @AlertID
      
   end
 
 Close curAlerts
 DeAllocate curAlerts
 
 --exec SendFAlert